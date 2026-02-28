import 'package:flutter/material.dart';

export '../../../todo/domain/models/todo_category.dart'
    show iconFromName, colorFromHex, iconToName, colorToHex, kIconNameMap, kCategoryIcons;

class LedgerCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const LedgerCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  LedgerCategory copyWith({String? name, Color? color, IconData? icon}) {
    return LedgerCategory(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) => other is LedgerCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
