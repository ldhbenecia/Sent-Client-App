import '../../domain/models/ledger_category.dart';

class LedgerCategoryDto {
  final int id;
  final String name;
  final String icon;
  final String color;

  const LedgerCategoryDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory LedgerCategoryDto.fromJson(Map<String, dynamic> json) =>
      LedgerCategoryDto(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String,
      );

  LedgerCategory toDomain() => LedgerCategory(
        id: id.toString(),
        name: name,
        icon: iconFromName(icon),
        color: colorFromHex(color),
      );
}
