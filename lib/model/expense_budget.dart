class ExpenseBudget {
  final String categoryCode;
  final String categoryName;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentOfTotalBudget;
  final int totalBudgetGaa;
  final int totalBudgetGaaPesos;
  final num percentDifferenceNepGaa;
  final int recordCount;
  final List<String> topSubObjects;

  ExpenseBudget({
    required this.categoryCode,
    required this.categoryName,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentOfTotalBudget,
    required this.totalBudgetGaa,
    required this.totalBudgetGaaPesos,
    required this.percentDifferenceNepGaa,
    required this.recordCount,
    required this.topSubObjects,
  });

  factory ExpenseBudget.fromJson(Map<String, dynamic> json) {
    return ExpenseBudget(
      categoryCode: json['categoryCode'] as String,
      categoryName: json['categoryName'] as String,
      totalBudget: json['totalBudget'] as int,
      totalBudgetPesos: json['totalBudgetPesos'] as int,
      percentOfTotalBudget: (json['percentOfTotalBudget'] as num).toDouble(),
      totalBudgetGaa: json['totalBudgetGaa'] as int,
      totalBudgetGaaPesos: json['totalBudgetGaaPesos'] as int,
      percentDifferenceNepGaa: json['percentDifferenceNepGaa'] as num,
      recordCount: json['recordCount'] as int,
      topSubObjects: List<String>.from(json['topSubObjects'] as List),
    );
  }
}