import '../../domain/models/todo_category.dart';

/// 서버 응답 DTO — GET /api/v1/categories, GET /api/v1/categories/{id}
class CategoryDto {
  final int id;
  final String name;
  final String icon;
  final String color;

  const CategoryDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String,
      );

  TodoCategory toDomain() => TodoCategory(
        id: id.toString(),
        name: name,
        icon: iconFromName(icon),
        color: colorFromHex(color),
      );
}
