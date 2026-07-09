// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectSubmission _$ProjectSubmissionFromJson(Map<String, dynamic> json) =>
    ProjectSubmission(
      id: (json['id'] as num).toInt(),
      subject: (json['subject'] as num).toInt(),
      subjectName: json['subject_name'] as String,
      projectFile: json['project_file'] as String?,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProjectSubmissionToJson(ProjectSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'subject_name': instance.subjectName,
      'project_file': instance.projectFile,
      'status': instance.status,
      'admin_notes': instance.adminNotes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
