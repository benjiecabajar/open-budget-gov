class DepartmentBudget {
  final String departmentCode;
  final String departmentName;
  final int totalBudget;
  final int totalBudgetPesos;
  final int recordCount;
  final double percentage;

  DepartmentBudget({
    required this.departmentCode,
    required this.departmentName,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.recordCount,
    required this.percentage,
  });

  factory DepartmentBudget.fromJson(Map<String, dynamic> json) {
    return DepartmentBudget(
      departmentCode: json['departmentCode'],
      departmentName: json['departmentName'],
      totalBudget: json['totalBudget'] as int? ?? 0,
      totalBudgetPesos: json['totalBudgetPesos'] as int? ?? 0,
      recordCount: json['recordCount'] as int? ?? 0,
      percentage: json['percentage'].toDouble(),
    );
  }
}
