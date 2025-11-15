class RegionalBudget {
  final String regionCode;
  final String regionName;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentage;
  final int recordCount;
  final List<String> byDepartment;

  RegionalBudget({
    required this.regionCode,
    required this.regionName,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentage,
    required this.recordCount,
    required this.byDepartment,
  });

factory RegionalBudget.fromJson(Map<String, dynamic> json) {
  int nepPesos = json['totalBudgetPesos'] as int;

  // If backend mistakenly multiplies by 1,000, fix it here
  if (nepPesos > 1e12) {
    nepPesos = nepPesos ~/ 1000;
  }

  return RegionalBudget(
    regionCode: json['regionCode'] as String,
    regionName: json['regionName'] as String,
    totalBudget: json['totalBudget'] as int,
    totalBudgetPesos: nepPesos,
    percentage: (json['percentage'] as num).toDouble(),
    recordCount: json['recordCount'] as int,
    byDepartment: List<String>.from(json['byDepartment'] as List),
  );
}
}