class OperatingUnitDetails {
  final String uacsCode;
  final String description;
  final String departmentCode;
  final String departmentDescription;
  final String agencyCode;
  final String agencyDescription;
  final int totalBudget;
  final int totalBudgetPesos;

  OperatingUnitDetails({
    required this.uacsCode,
    required this.description,
    required this.departmentCode,
    required this.departmentDescription,
    required this.agencyCode,
    required this.agencyDescription,
    required this.totalBudget,
    required this.totalBudgetPesos,
  });

  factory OperatingUnitDetails.fromJson(Map<String, dynamic> json) {
    return OperatingUnitDetails(
      uacsCode: json['uacsCode'] as String,
      description: json['description'] as String,
      departmentCode: json['departmentCode'] as String,
      departmentDescription: json['departmentDescription'] as String,
      agencyCode: json['agencyCode'] as String,
      agencyDescription: json['agencyDescription'] as String,
      totalBudget: json['totalBudget'] as int,
      totalBudgetPesos: json['totalBudgetPesos'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uacsCode': uacsCode,
      'description': description,
      'departmentCode': departmentCode,
      'departmentDescription': departmentDescription,
      'agencyCode': agencyCode,
      'agencyDescription': agencyDescription,
      'totalBudget': totalBudget,
      'totalBudgetPesos': totalBudgetPesos,
    };
  }
}