// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  chapters:
      (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isLocked: json['is_locked'] as bool? ?? true,
  certificationAvailable: json['certification_available'] as bool? ?? false,
  isPopular: json['is_popular'] as bool? ?? false,
  popularOrder: (json['popular_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_locked': instance.isLocked,
  'certification_available': instance.certificationAvailable,
  'is_popular': instance.isPopular,
  'popular_order': instance.popularOrder,
  'chapters': instance.chapters,
};
