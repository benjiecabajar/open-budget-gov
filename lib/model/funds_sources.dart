class FundSource {
  final String uacsCode;
  final String description;
  final String? clusterCode;
  final String? clusterDescription;
  final int totalBudget;
  final int totalBudgetPesos;

  FundSource({
    required this.uacsCode,
    required this.description,
    this.clusterCode,
    this.clusterDescription,
    required this.totalBudget,
    required this.totalBudgetPesos,
  });

  factory FundSource.fromJson(Map<String, dynamic> json) {
    return FundSource(
      uacsCode: json['uacsCode'] as String,
      description: json['description'] as String,
      clusterCode: json['clusterCode'] as String?,
      clusterDescription: json['clusterDescription'] as String?,
      totalBudget: json['totalBudget'] as int? ?? 0,
      totalBudgetPesos: json['totalBudgetPesos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uacsCode': uacsCode,
      'description': description,
      'clusterCode': clusterCode,
      'clusterDescription': clusterDescription,
      'totalBudget': totalBudget,
      'totalBudgetPesos': totalBudgetPesos,
    };
  }
}