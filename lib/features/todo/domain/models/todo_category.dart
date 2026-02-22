import 'package:flutter/material.dart';

// ── 아이콘 이름 ↔ IconData 양방향 맵 ────────────────────────────────
const Map<String, IconData> kIconNameMap = {
  'work': Icons.work_rounded,
  'book': Icons.menu_book_rounded,
  'home': Icons.home_rounded,
  'person': Icons.person_rounded,
  'camera': Icons.camera_alt_rounded,
  'star': Icons.star_rounded,
  'heart': Icons.favorite_rounded,
  'fitness': Icons.fitness_center_rounded,
  'music': Icons.music_note_rounded,
  'edit': Icons.edit_rounded,
  'shopping': Icons.shopping_cart_rounded,
  'food': Icons.restaurant_rounded,
  'coffee': Icons.local_cafe_rounded,
  'car': Icons.directions_car_rounded,
  'flight': Icons.flight_rounded,
  'spa': Icons.spa_rounded,
  'sports': Icons.sports_basketball_rounded,
  'palette': Icons.palette_rounded,
  'emoji': Icons.emoji_emotions_rounded,
  'thumbs_up': Icons.thumb_up_rounded,
  'savings': Icons.savings_rounded,
  'health': Icons.health_and_safety_rounded,
};

/// 아이콘 이름 → IconData (없으면 work 반환)
IconData iconFromName(String name) =>
    kIconNameMap[name] ?? Icons.work_rounded;

/// IconData → 아이콘 이름 (없으면 'work' 반환)
String iconToName(IconData icon) =>
    kIconNameMap.entries
        .firstWhere(
          (e) => e.value == icon,
          orElse: () => const MapEntry('work', Icons.work_rounded),
        )
        .key;

/// "#RRGGBB" → Color
Color colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

/// Color → "#RRGGBB"
String colorToHex(Color c) {
  final argb = c.toARGB32();
  return '#${argb.toRadixString(16).toUpperCase().substring(2)}';
}

// ── 도메인 모델 ──────────────────────────────────────────────────────
class TodoCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const TodoCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  TodoCategory copyWith({String? name, Color? color, IconData? icon}) {
    return TodoCategory(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) => other is TodoCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ── UI에서 선택 가능한 아이콘 목록 ──────────────────────────────────
const List<IconData> kCategoryIcons = [
  Icons.work_rounded,
  Icons.menu_book_rounded,
  Icons.home_rounded,
  Icons.person_rounded,
  Icons.camera_alt_rounded,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.fitness_center_rounded,
  Icons.music_note_rounded,
  Icons.edit_rounded,
  Icons.shopping_cart_rounded,
  Icons.restaurant_rounded,
  Icons.local_cafe_rounded,
  Icons.directions_car_rounded,
  Icons.flight_rounded,
  Icons.spa_rounded,
  Icons.sports_basketball_rounded,
  Icons.palette_rounded,
  Icons.emoji_emotions_rounded,
  Icons.thumb_up_rounded,
  Icons.savings_rounded,
  Icons.health_and_safety_rounded,
];
