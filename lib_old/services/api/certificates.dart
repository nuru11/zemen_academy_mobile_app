import 'dart:io';

import 'package:get/get.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/api/api.dart';
import 'package:vector_academy/services/api/exceptions.dart';
import 'package:vector_academy/utils/utils.dart';

class CertificateService extends GetxController {
  final ApiClient apiClient = ApiClient();

  Future<List<ProjectSubmission>> getProjectSubmissions(String deviceId) async {
    try {
      final response = await apiClient.get(
        '/app/project-submissions/',
        authenticated: true,
        queryParameters: {'device': deviceId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data
            .map((json) => ProjectSubmission.fromJson(json))
            .toList();
      }
      throw ApiException('Failed to load project submissions');
    } catch (e) {
      logger.e('Error loading project submissions: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load project submissions');
    }
  }

  Future<ProjectSubmission> submitProject({
    required String deviceId,
    required int subjectId,
    required File projectFile,
  }) async {
    try {
      final response = await apiClient.uploadFile(
        '/app/project-submissions/',
        filePath: projectFile.path,
        fieldName: 'project_file',
        additionalData: {
          'subject': subjectId,
          'device': deviceId,
        },
        authenticated: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjectSubmission.fromJson(response.data);
      }

      final errorMessage = _extractErrorMessage(response.data);
      throw ApiException(errorMessage);
    } catch (e) {
      logger.e('Error submitting project: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to submit project');
    }
  }

  Future<List<Certificate>> getCertificates(String deviceId) async {
    try {
      final response = await apiClient.get(
        '/app/certificates/',
        authenticated: true,
        queryParameters: {'device': deviceId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data.map((json) => Certificate.fromJson(json)).toList();
      }
      throw ApiException('Failed to load certificates');
    } catch (e) {
      logger.e('Error loading certificates: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load certificates');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      if (data['subject'] is List && (data['subject'] as List).isNotEmpty) {
        return (data['subject'] as List).first.toString();
      }
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data['error']?['message'] != null) {
        return data['error']['message'].toString();
      }
    }
    return 'Failed to submit project';
  }
}
