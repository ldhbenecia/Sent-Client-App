class TodoStatistics {
  final int year;
  final int month;
  final int totalCount;
  final int completedCount;
  final double completionRate;
  final List<CategoryStatistic> categoryBreakdown;

  const TodoStatistics({
    required this.year,
    required this.month,
    required this.totalCount,
    required this.completedCount,
    required this.completionRate,
    required this.categoryBreakdown,
  });

  factory TodoStatistics.empty(int year, int month) => TodoStatistics(
        year: year,
        month: month,
        totalCount: 0,
        completedCount: 0,
        completionRate: 0.0,
        categoryBreakdown: [],
      );

  factory TodoStatistics.fromJson(Map<String, dynamic> json) {
    final total = json['totalCount'] as int;
    final done = json['doneCount'] as int;
    final rate = total > 0 ? (done / total * 100.0) : 0.0;
    return TodoStatistics(
      year: json['year'] as int,
      month: json['month'] as int,
      totalCount: total,
      completedCount: done,
      completionRate: rate,
      categoryBreakdown: (json['categoryBreakdown'] as List)
          .map((e) => CategoryStatistic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryStatistic {
  final String? categoryId;
  final String? categoryName;
  final int totalCount;
  final int completedCount;

  const CategoryStatistic({
    required this.categoryId,
    required this.categoryName,
    required this.totalCount,
    required this.completedCount,
  });

  factory CategoryStatistic.fromJson(Map<String, dynamic> json) =>
      CategoryStatistic(
        categoryId: json['categoryId']?.toString(),
        categoryName: json['categoryName'] as String?,
        totalCount: json['totalCount'] as int,
        completedCount: json['doneCount'] as int,
      );
}
