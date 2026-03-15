import '../../../todo/domain/models/todo_category.dart'
    show iconFromName, colorFromHex;
import '../../domain/models/memo_category.dart';
import '../../domain/models/memo_item.dart';

/// 서버 응답 DTO — GET /api/v1/memos/categories
class MemoCategoryDto {
  final int id;
  final String name;
  final String icon;
  final String color;

  const MemoCategoryDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory MemoCategoryDto.fromJson(Map<String, dynamic> json) =>
      MemoCategoryDto(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String,
      );

  MemoCategory toDomain() => MemoCategory(
        id: id.toString(),
        name: name,
        icon: iconFromName(icon),
        color: colorFromHex(color),
      );
}

/// 서버 응답 DTO — GET /api/v1/memos
class MemoItemDto {
  final int id;
  final String title;
  final String? content;
  final MemoCategoryDto? category;
  final List<String> tags;

  const MemoItemDto({
    required this.id,
    required this.title,
    this.content,
    this.category,
    this.tags = const [],
  });

  factory MemoItemDto.fromJson(Map<String, dynamic> json) => MemoItemDto(
        id: json['id'] as int,
        title: json['title'] as String,
        content: json['content'] as String?,
        category: json['category'] != null
            ? MemoCategoryDto.fromJson(
                json['category'] as Map<String, dynamic>)
            : null,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  MemoItem toDomain() => MemoItem(
        id: id.toString(),
        title: title,
        content: content,
        category: category?.toDomain(),
        tags: tags,
      );
}
