class RegionalBudget {
  final String regionCode;
  final String regionName;

  RegionalBudget({
    required this.regionCode,
    required this.regionName,
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
  );
}
}