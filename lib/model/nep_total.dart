class TotalBudget {
  final int total;
  final int totalInPesos;
  final String currency;
  final Filters filters;

  TotalBudget({
    required this.total,
    required this.totalInPesos,
    required this.currency,
    required this.filters,
  });

  factory TotalBudget.fromJson(Map<String, dynamic> json) {
    return TotalBudget(
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

  Filters({
    required this.year,
    required this.type,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      year: json['year'] as String,
      type: json['type'] as String,
    );
  }
}
