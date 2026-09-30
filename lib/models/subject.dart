import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vector_academy/models/models.dart';
part 'subject.g.dart';

@JsonSerializable()
class Subject {
  final int id;
  final String name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_locked')
  final bool isLocked;
  @JsonKey(name: 'certification_available', defaultValue: false)
  final bool certificationAvailable;
  @JsonKey(name: 'is_popular', defaultValue: false)
  final bool isPopular;
  @JsonKey(name: 'popular_order', defaultValue: 0)
  final int popularOrder;

  final List<Chapter> chapters;

  Subject({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.chapters = const [],
    this.isLocked = true,
    this.certificationAvailable = false,
    this.isPopular = false,
    this.popularOrder = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

class SubjectTypeAdapter implements TypeAdapter<Subject> {
  @override
  read(BinaryReader reader) {
    final json = reader.read() as Map<dynamic, dynamic>;
    return Subject(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      chapters: Chapter.listFromCache(json['chapters']),
      isLocked: json['is_locked'] ?? true,
      certificationAvailable: json['certification_available'] ?? false,
      isPopular: json['is_popular'] ?? false,
      popularOrder: (json['popular_order'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  int get typeId => 7;

  @override
  void write(BinaryWriter writer, Subject obj) {
    final json = obj.toJson();
    json['chapters'] = obj.chapters.map((chapter) => chapter.toJson()).toList();
    writer.write(json);
  }
}
