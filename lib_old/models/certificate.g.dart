// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Certificate _$CertificateFromJson(Map<String, dynamic> json) => Certificate(
  id: (json['id'] as num).toInt(),
  subject: (json['subject'] as num).toInt(),
  subjectName: json['subject_name'] as String,
  certificateNumber: json['certificate_number'] as String,
  pdfUrl: json['pdf_url'] as String?,
  issuedAt: DateTime.parse(json['issued_at'] as String),
);

Map<String, dynamic> _$CertificateToJson(Certificate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'subject_name': instance.subjectName,
      'certificate_number': instance.certificateNumber,
      'pdf_url': instance.pdfUrl,
      'issued_at': instance.issuedAt.toIso8601String(),
    };
