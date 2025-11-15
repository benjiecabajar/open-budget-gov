class ListOfRegions {
  final String code;
  final String description;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentOfTotalBudget;
  final int totalBudgetGaa;
  final int totalBudgetGaaPesos;
  final num percentDifferenceNepGaa;

  ListOfRegions({
    required this.code,
    required this.description,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentOfTotalBudget,
    required this.totalBudgetGaa,
    required this.totalBudgetGaaPesos,
    required this.percentDifferenceNepGaa,
  });

  factory ListOfRegions.fromJson(Map<String, dynamic> json) {
    return ListOfRegions(
      code: json['code'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'Unknown',
      totalBudget: (json['totalBudget'] ?? 0) as int,
      totalBudgetPesos: (json['totalBudgetPesos'] ?? 0) as int,
      percentOfTotalBudget: ((json['percentOfTotalBudget'] ?? 0) as num).toDouble(),
      totalBudgetGaa: (json['totalBudgetGaa'] ?? 0) as int,
      totalBudgetGaaPesos: (json['totalBudgetGaaPesos'] ?? 0) as int,
      percentDifferenceNepGaa: (json['percentDifferenceNepGaa'] ?? 0) as num,
    );
  }
}