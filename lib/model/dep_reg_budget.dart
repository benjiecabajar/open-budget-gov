class DepartmentRegionalBudget {
  final int total;
  final int totalInPesos;
  final String currency;
  final Filters filters;

  DepartmentRegionalBudget({
    required this.total,
    required this.totalInPesos,
    required this.currency,
    required this.filters,
  });

  factory DepartmentRegionalBudget.fromJson(Map<String, dynamic> json) {
    return DepartmentRegionalBudget(
      total: json['total'] as int? ?? 0,
      totalInPesos: json['totalInPesos'] as int? ?? 0,
      currency: json['currency'] as String,
      filters: Filters.fromJson(json['filters'] as Map<String, dynamic>),
    );
  }
}

class Filters {
  final String year;
  final String type;
  final String department;
  final String region;

  Filters({
    required this.year,
    required this.type,
    required this.department,
    required this.region,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      year: json['year'] as String,
      type: json['type'] as String,
      department: json['department'] as String,
      region: json['region'] as String,
    );
  }
}