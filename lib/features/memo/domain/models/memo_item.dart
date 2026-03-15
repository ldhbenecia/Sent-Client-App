import 'memo_category.dart';

class MemoItem {
  final String id;
  final String title;
  final String? content;
  final MemoCategory? category;
  final List<String> tags;

  const MemoItem({
    required this.id,
    required this.title,
    this.content,
    this.category,
    this.tags = const [],
  });

  MemoItem copyWith({
    String? title,
    String? content,
    MemoCategory? category,
    List<String>? tags,
    bool clearCategory = false,
    bool clearContent = false,
  }) {
    return MemoItem(
      id: id,
      title: title ?? this.title,
      content: clearContent ? null : (content ?? this.content),
      category: clearCategory ? null : (category ?? this.category),
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) => other is MemoItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
