import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
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
  final Map<int, File> _pendingProjectFiles = {};

  bool hasPendingFile(int subjectId) =>
      _pendingProjectFiles.containsKey(subjectId);

  String? pendingFileName(int subjectId) {
    final path = _pendingProjectFiles[subjectId]?.path;
    if (path == null) return null;
    return path.split(RegExp(r'[/\\]')).last;
  }

  void clearPendingFile(int subjectId) {
    _pendingProjectFiles.remove(subjectId);
    update();
  }

  void _syncPendingFiles() {
    final activeSubjectIds = _courseItems
        .where(canSubmit)
        .map((item) => item.subject.id)
        .toSet();
    _pendingProjectFiles.removeWhere(
      (subjectId, _) => !activeSubjectIds.contains(subjectId),
    );
  }

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
      _courseItems = subjects
          .where((subject) => subject.certificationAvailable)
          .map((subject) {
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
      _syncPendingFiles();
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

  bool _isSubjectLocked(Subject subject) {
    return subject.isLocked &&
        !hasFullAccessOverrideForPhone(_user?.phoneNumber);
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
        case 'approved':
          return CourseCertificationStatus.certified;
        case 'rejected':
          if (_isSubjectLocked(subject)) {
            return CourseCertificationStatus.locked;
          }
          return CourseCertificationStatus.rejected;
      }
    }
    if (_isSubjectLocked(subject)) {
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

  void openUnlockCourse(CourseCertificationItem item) {
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
  }

  String _certificateDisplayName() {
    final authUser = Get.isRegistered<CoreService>()
        ? Get.find<CoreService>().authService.user.value
        : null;
    final user = authUser ?? _user;
    if (user == null) return 'Student';

    final name = '${user.firstName} ${user.lastName ?? ''}'.trim();
    return name.isEmpty ? 'Student' : name;
  }

  Future<bool> _showCertificateNameDialog() async {
    final context = Get.context;
    if (context == null) return false;

    final displayName = _certificateDisplayName();
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check your certificate name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If your project is approved, this name from your profile will be '
              'printed on your certificate. Edit your profile first if it is incorrect.',
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
              Get.toNamed(VIEWS.editProfile.path);
            },
            child: const Text('Edit profile'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return shouldContinue == true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized || _deviceId == null) {
      await loadCertificationData();
    }
  }

  bool _guardUnlock(CourseCertificationItem item) {
    if (item.status == CourseCertificationStatus.locked ||
        _isSubjectLocked(item.subject)) {
      openUnlockCourse(item);
      return false;
    }
    return true;
  }

  Future<void> pickProjectFile(CourseCertificationItem item) async {
    await _ensureInitialized();
    if (_deviceId == null) return;
    if (!_guardUnlock(item)) return;

    final shouldContinue = await _showCertificateNameDialog();
    if (!shouldContinue) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    _pendingProjectFiles[item.subject.id] = File(result.files.single.path!);
    update();
  }

  Future<void> changeProjectFile(CourseCertificationItem item) async {
    clearPendingFile(item.subject.id);
    await pickProjectFile(item);
  }

  Future<void> uploadPendingProject(CourseCertificationItem item) async {
    await _ensureInitialized();
    if (_deviceId == null) return;

    final projectFile = _pendingProjectFiles[item.subject.id];
    if (projectFile == null) {
      AppSnackbar.showError(
        'No file selected',
        'Please select a project file before submitting.',
      );
      return;
    }

    _isSubmitting = true;
    update();

    try {
      await _certificateService.submitProject(
        deviceId: _deviceId!,
        subjectId: item.subject.id,
        projectFile: projectFile,
      );
      _pendingProjectFiles.remove(item.subject.id);
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
        pdfTitle: '${certificate.subjectName} Certificate',
        pdfId: certificate.id,
        showShareButton: true,
        certificateNumber: certificate.certificateNumber,
      ),
    );
  }

  bool canSubmit(CourseCertificationItem item) {
    if (_isSubjectLocked(item.subject)) return false;
    return item.status == CourseCertificationStatus.notSubmitted ||
        item.status == CourseCertificationStatus.rejected;
  }
}
