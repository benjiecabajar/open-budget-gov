/// Represents a summary of budget allocation for a specific region.
class RegionalBudgetSummary {
  final String regionCode;
  final String regionName;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentage;
  final int recordCount;
  final List<String> byDepartment;

  RegionalBudgetSummary({
    required this.regionCode,
    required this.regionName,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentage,
    required this.recordCount,
    required this.byDepartment,
  });

  /// Creates a [RegionalBudgetSummary] instance from a JSON map.
  ///
  /// This factory constructor handles the parsing of the JSON data into the
  /// corresponding fields of the class, including type casting and providing
  /// default values for safety.
  factory RegionalBudgetSummary.fromJson(Map<String, dynamic> json) {
    return RegionalBudgetSummary(
      regionCode: json['regionCode'] as String? ?? '',
      regionName: json['regionName'] as String? ?? '',
      totalBudget: json['totalBudget'] as int? ?? 0,
      totalBudgetPesos: json['totalBudgetPesos'] as int? ?? 0,
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
      recordCount: json['recordCount'] as int? ?? 0,
      byDepartment: (json['byDepartment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}