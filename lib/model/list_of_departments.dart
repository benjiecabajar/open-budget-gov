class ListOfAllDepartmets {
  final String code;
  final String description;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentOfTotalBudget;
  final int totalBudgetGaa;
  final int totalBudgetGaaPesos;
  final double percentDifferenceNepGaa;
  final int totalAgencies;

  ListOfAllDepartmets({
    required this.code,
    required this.description,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentOfTotalBudget,
    required this.totalBudgetGaa,
    required this.totalBudgetGaaPesos,
    required this.percentDifferenceNepGaa,
    required this.totalAgencies,
  });

  factory ListOfAllDepartmets.fromJson(Map<String, dynamic> json) {
    return ListOfAllDepartmets(
      code: json['code'] as String,
      description: json['description'] as String,
      totalBudget: json['totalBudget'] as int,
      totalBudgetPesos: json['totalBudgetPesos'] as int,
      percentOfTotalBudget: (json['percentOfTotalBudget'] is num)
          ? (json['percentOfTotalBudget'] as num).toDouble()
          : 0.0,
      totalBudgetGaa: json['totalBudgetGaa'] as int,
      totalBudgetGaaPesos: json['totalBudgetGaaPesos'] as int,
      percentDifferenceNepGaa: (json['percentDifferenceNepGaa'] is num)
          ? (json['percentDifferenceNepGaa'] as num).toDouble()
          : 0.0,
      totalAgencies: json['totalAgencies'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'totalBudget': totalBudget,
      'totalBudgetPesos': totalBudgetPesos,
      'percentOfTotalBudget': percentOfTotalBudget,
      'totalBudgetGaa': totalBudgetGaa,
      'totalBudgetGaaPesos': totalBudgetGaaPesos,
      'percentDifferenceNepGaa': percentDifferenceNepGaa,
      'totalAgencies': totalAgencies,
    };
  }
}
