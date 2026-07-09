import 'package:json_annotation/json_annotation.dart';

part 'project_submission.g.dart';

@JsonSerializable()
class ProjectSubmission {
  final int id;
  final int subject;
  @JsonKey(name: 'subject_name')
  final String subjectName;
  @JsonKey(name: 'project_file')
  final String? projectFile;
  final String status;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ProjectSubmission({
    required this.id,
    required this.subject,
    required this.subjectName,
    this.projectFile,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProjectSubmission.fromJson(Map<String, dynamic> json) =>
      _$ProjectSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSubmissionToJson(this);
}
