import 'package:flutter/material.dart';

// ── 도메인 모델 ──────────────────────────────────────────────────────
class MemoCategory {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  const MemoCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  MemoCategory copyWith({String? name, Color? color, IconData? icon}) {
    return MemoCategory(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) => other is MemoCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
