import 'package:json_annotation/json_annotation.dart';

part 'certificate.g.dart';

@JsonSerializable()
class Certificate {
  final int id;
  final int subject;
  @JsonKey(name: 'subject_name')
  final String subjectName;
  @JsonKey(name: 'certificate_number')
  final String certificateNumber;
  @JsonKey(name: 'pdf_url')
  final String? pdfUrl;
  @JsonKey(name: 'issued_at')
  final DateTime issuedAt;

  Certificate({
    required this.id,
    required this.subject,
    required this.subjectName,
    required this.certificateNumber,
    this.pdfUrl,
    required this.issuedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);
}
