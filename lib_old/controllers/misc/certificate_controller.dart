import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/utils/access_override.dart';
import 'package:vector_academy/utils/device/device.dart';
import 'package:vector_academy/utils/storages/storages.dart';
import 'package:vector_academy/utils/utils.dart';
import 'package:vector_academy/views/views.dart';

enum CourseCertificationStatus {
  notSubmitted,
  pending,
  rejected,
  certified,
  locked,
}

class CourseCertificationItem {
  CourseCertificationItem({
    required this.subject,
    required this.status,
    this.submission,
    this.certificate,
  });

  final Subject subject;
  final CourseCertificationStatus status;
  final ProjectSubmission? submission;
  final Certificate? certificate;
}

class CertificateController extends GetxController {
  final CertificateService _certificateService = CertificateService();
  final SubjectsService _subjectsService = SubjectsService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _initialized = false;

  List<CourseCertificationItem> _courseItems = [];
  List<CourseCertificationItem> get courseItems => _courseItems;

  List<Certificate> _certificates = [];
  List<Certificate> get certificates => _certificates;

  User? _user;
  String? _deviceId;

  Future<void> loadCertificationData() async {
    if (_isLoading) return;

    if (!_initialized) {
      _user = await HiveUserStorage().getUser();
      final device = await UserDevice.getDeviceInfo(_user?.phoneNumber ?? '');
      _deviceId = device.id;
      _initialized = true;
    }

    if (_user == null || _deviceId == null) return;

    _isLoading = true;
    update();

    try {
      final subjects = await _subjectsService.getSubjects(
        _deviceId!,
        gradeId: _user!.grade.id,
      );
      final submissions = await _certificateService.getProjectSubmissions(
        _deviceId!,
      );
      final certificates = await _certificateService.getCertificates(
        _deviceId!,
      );

      _certificates = certificates;
      _courseItems = subjects.map((subject) {
        final submission = _latestSubmissionForSubject(submissions, subject.id);
        Certificate? certificate;
        for (final cert in certificates) {
          if (cert.subject == subject.id) {
            certificate = cert;
            break;
          }
        }

        return CourseCertificationItem(
          subject: subject,
          submission: submission,
          certificate: certificate,
          status: _resolveStatus(
            subject: subject,
            submission: submission,
            certificate: certificate,
          ),
        );
      }).toList();
    } catch (e) {
      logger.e('Failed to load certification data: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  ProjectSubmission? _latestSubmissionForSubject(
    List<ProjectSubmission> submissions,
    int subjectId,
  ) {
    for (final submission in submissions) {
      if (submission.subject == subjectId) {
        return submission;
      }
    }
    return null;
  }

  CourseCertificationStatus _resolveStatus({
    required Subject subject,
    ProjectSubmission? submission,
    Certificate? certificate,
  }) {
    if (certificate != null) {
      return CourseCertificationStatus.certified;
    }
    if (submission != null) {
      switch (submission.status) {
        case 'pending':
          return CourseCertificationStatus.pending;
        case 'rejected':
          return CourseCertificationStatus.rejected;
        case 'approved':
          return CourseCertificationStatus.certified;
      }
    }
    if (subject.isLocked && !hasFullAccessOverrideForPhone(_user?.phoneNumber)) {
      return CourseCertificationStatus.locked;
    }
    return CourseCertificationStatus.notSubmitted;
  }

  String statusLabel(CourseCertificationStatus status) {
    switch (status) {
      case CourseCertificationStatus.notSubmitted:
        return 'Not submitted';
      case CourseCertificationStatus.pending:
        return 'Pending review';
      case CourseCertificationStatus.rejected:
        return 'Rejected';
      case CourseCertificationStatus.certified:
        return 'Certified';
      case CourseCertificationStatus.locked:
        return 'Subscription required';
    }
  }

  Color statusColor(CourseCertificationStatus status) {
    switch (status) {
      case CourseCertificationStatus.notSubmitted:
        return Colors.grey;
      case CourseCertificationStatus.pending:
        return Colors.orange;
      case CourseCertificationStatus.rejected:
        return Colors.red;
      case CourseCertificationStatus.certified:
        return Colors.green;
      case CourseCertificationStatus.locked:
        return Colors.blueGrey;
    }
  }

  Future<void> submitProject(CourseCertificationItem item) async {
    if (!_initialized || _deviceId == null) {
      await loadCertificationData();
    }
    if (_deviceId == null) return;

    if (item.status == CourseCertificationStatus.locked) {
      AppSnackbar.showInfo(
        'Subscription Required',
        'Pay once to unlock this ${subjectLabel.toLowerCase()} before submitting a project.',
      );
      Get.toNamed(
        VIEWS.payments.path,
        arguments: {
          'subjectId': item.subject.id,
          'subjectName': item.subject.name,
        },
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    _isSubmitting = true;
    update();

    try {
      await _certificateService.submitProject(
        deviceId: _deviceId!,
        subjectId: item.subject.id,
        projectFile: File(result.files.single.path!),
      );
      AppSnackbar.showSuccess(
        'Submitted',
        'Your project is pending admin review.',
      );
      await loadCertificationData();
    } catch (e) {
      AppSnackbar.showError('Submission failed', e.toString());
    } finally {
      _isSubmitting = false;
      update();
    }
  }

  void openCertificate(Certificate certificate) {
    final pdfUrl = certificate.pdfUrl;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      AppSnackbar.showError('Error', 'Certificate PDF is not available yet.');
      return;
    }

    Get.to(
      () => PDFReaderScreen(
        pdfUrl: pdfUrl,
        pdfTitle: certificate.subjectName,
        pdfId: certificate.id,
      ),
    );
  }

  bool canSubmit(CourseCertificationItem item) {
    return item.status == CourseCertificationStatus.notSubmitted ||
        item.status == CourseCertificationStatus.rejected;
  }
}
