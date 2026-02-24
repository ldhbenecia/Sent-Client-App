import 'package:flutter/material.dart';

// ── 아이콘 이름 ↔ IconData 양방향 맵 ────────────────────────────────
const Map<String, IconData> kIconNameMap = {
  // 생산성 / 일상
  'Work':     Icons.work_rounded,
  'Study':    Icons.menu_book_rounded,
  'Home':     Icons.home_rounded,
  'Note':     Icons.edit_rounded,
  'Code':     Icons.code_rounded,
  // 소비 / 생활
  'Shopping': Icons.shopping_bag_rounded,
  'Food':     Icons.restaurant_rounded,
  'Coffee':   Icons.local_cafe_rounded,
  'Money':    Icons.savings_rounded,
  'Car':      Icons.directions_car_rounded,
  // 건강 / 운동
  'Health':   Icons.fitness_center_rounded,
  'Sports':   Icons.sports_basketball_rounded,
  'Spa':      Icons.spa_rounded,
  // 취미 / 여가
  'Music':    Icons.headphones_rounded,
  'Art':      Icons.palette_rounded,
  'Game':     Icons.sports_esports_rounded,
  'Camera':   Icons.camera_alt_rounded,
  // 사람 / 감정
  'People':   Icons.people_rounded,
  'Person':   Icons.person_rounded,
  'Heart':    Icons.favorite_rounded,
  'Star':     Icons.star_rounded,
  // 여행
  'Travel':   Icons.flight_rounded,
};

/// 아이콘 이름 → IconData (없으면 Work 반환)
IconData iconFromName(String name) =>
    kIconNameMap[name] ?? Icons.work_rounded;

/// IconData → 아이콘 이름 (없으면 'Work' 반환)
String iconToName(IconData icon) =>
    kIconNameMap.entries
        .firstWhere(
          (e) => e.value == icon,
          orElse: () => const MapEntry('Work', Icons.work_rounded),
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

// ── UI에서 선택 가능한 아이콘 목록 (자주 쓰는 순) ──────────────────
const List<IconData> kCategoryIcons = [
  // 생산성 / 일상
  Icons.work_rounded,
  Icons.menu_book_rounded,
  Icons.home_rounded,
  Icons.edit_rounded,
  Icons.code_rounded,
  // 소비 / 생활
  Icons.shopping_bag_rounded,
  Icons.restaurant_rounded,
  Icons.local_cafe_rounded,
  Icons.savings_rounded,
  Icons.directions_car_rounded,
  // 건강 / 운동
  Icons.fitness_center_rounded,
  Icons.sports_basketball_rounded,
  Icons.spa_rounded,
  // 취미 / 여가
  Icons.headphones_rounded,
  Icons.palette_rounded,
  Icons.sports_esports_rounded,
  Icons.camera_alt_rounded,
  // 사람 / 감정
  Icons.people_rounded,
  Icons.person_rounded,
  Icons.favorite_rounded,
  Icons.star_rounded,
  // 여행
  Icons.flight_rounded,
];
