// Minimal Agency model for use in agency_cards.dart and DepartmentDetails
class Agency {
  final String code;
  final String description;
  final String uacsCode;
  final int budget;
  final int budgetPesos;
  final int? nepBudgetPesos;
  final int? gaaBudgetPesos;

  Agency({
    required this.code,
    required this.description,
    required this.uacsCode,
    required this.budget,
    required this.budgetPesos,
    this.nepBudgetPesos,
    this.gaaBudgetPesos,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      uacsCode: json['uacsCode'] ?? '',
      budget: json['budget'] ?? 0,
      budgetPesos: json['budgetPesos'] ?? 0,
      nepBudgetPesos: json['nepBudgetPesos'] as int?,
      gaaBudgetPesos: json['gaaBudgetPesos'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'uacsCode': uacsCode,
      'budget': budget,
      'budgetPesos': budgetPesos,
      'nepBudgetPesos': nepBudgetPesos,
      'gaaBudgetPesos': gaaBudgetPesos,
    };
  }

  Agency copyWith({
    int? nepBudgetPesos,
    int? gaaBudgetPesos,
  }) {
    return Agency(
      code: code,
      description: description,
      uacsCode: uacsCode,
      budget: budget,
      budgetPesos: budgetPesos,
      nepBudgetPesos: nepBudgetPesos ?? this.nepBudgetPesos,
      gaaBudgetPesos: gaaBudgetPesos ?? this.gaaBudgetPesos,
    );
  }
}
// import 'package:budget_gov/model/org.dart';

class DepartmentDetails {
  final String code;
  final String description;
  final String abbreviation;
  final int totalBudget;
  final int totalBudgetPesos;
  final List<Agency> agencies;
  final List<OperatingUnit> operatingUnits;
  final List<RegionBudget> regions;
  final List<FundingSource> fundingSources;
  final List<ExpenseCategory> expenseCategories;
  final Statistics statistics;

  DepartmentDetails({
    required this.code,
    required this.description,
    required this.abbreviation,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.agencies,
    required this.operatingUnits,
    required this.regions,
    required this.fundingSources,
    required this.expenseCategories,
    required this.statistics,
  });

  factory DepartmentDetails.fromJson(Map<String, dynamic> json) {
  return DepartmentDetails(
    code: json['code'] as String,
    description: json['description'] as String,
    abbreviation: json['abbreviation'] as String,
    totalBudget: json['totalBudget'] is int
      ? json['totalBudget'] as int
      : (json['totalBudget'] ?? 0) is String
        ? int.tryParse(json['totalBudget'] ?? '0') ?? 0
        : (json['totalBudget'] ?? 0) as int,
    totalBudgetPesos: json['totalBudgetPesos'] is int
      ? json['totalBudgetPesos'] as int
      : (json['totalBudgetPesos'] ?? 0) is String
        ? int.tryParse(json['totalBudgetPesos'] ?? '0') ?? 0
        : (json['totalBudgetPesos'] ?? 0) as int,
    agencies: (json['agencies'] as List<dynamic>? ?? [])
      .map((e) => Agency.fromJson(e as Map<String, dynamic>))
      .toList(),
    operatingUnits: (json['operatingUnits'] as List<dynamic>? ?? [])
      .map((e) => OperatingUnit.fromJson(e as Map<String, dynamic>))
      .toList(),
    regions: (json['regions'] as List<dynamic>? ?? [])
      .map((e) => RegionBudget.fromJson(e as Map<String, dynamic>))
      .toList(),
    fundingSources: (json['fundingSources'] as List<dynamic>? ?? [])
      .map((e) => FundingSource.fromJson(e as Map<String, dynamic>))
      .toList(),
    expenseCategories: (json['expenseCategories'] as List<dynamic>? ?? [])
      .map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
    statistics: Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
  );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'abbreviation': abbreviation,
      'totalBudget': totalBudget,
      'totalBudgetPesos': totalBudgetPesos,
      'agencies': agencies.map((e) => e.toJson()).toList(),
      'operatingUnits': operatingUnits.map((e) => e.toJson()).toList(),
      'regions': regions.map((e) => e.toJson()).toList(),
      'fundingSources': fundingSources.map((e) => e.toJson()).toList(),
      'expenseCategories': expenseCategories.map((e) => e.toJson()).toList(),
      'statistics': statistics.toJson(),
    };
  }
}

class OperatingUnit {
  final String code;
  final String description;
  final String uacsCode;
  final String agencyCode;
  final int budget;
  final int budgetPesos;
  final int? nepBudgetPesos;
  final int? gaaBudgetPesos;

  OperatingUnit({
    required this.code,
    required this.description,
    required this.uacsCode,
    required this.agencyCode,
    required this.budget,
    required this.budgetPesos,
    this.nepBudgetPesos,
    this.gaaBudgetPesos,
  });

  factory OperatingUnit.fromJson(Map<String, dynamic> json) => OperatingUnit(
        code: json['code'] as String,
        description: json['description'] as String,
        uacsCode: json['uacsCode'] as String,
        agencyCode: json['agencyCode'] as String,
        budget: json['budget'] is int
            ? json['budget'] as int
            : (json['budget'] ?? 0) is String
                ? int.tryParse(json['budget'] ?? '0') ?? 0
                : (json['budget'] ?? 0) as int,
        budgetPesos: json['budgetPesos'] is int
            ? json['budgetPesos'] as int
            : (json['budgetPesos'] ?? 0) is String
                ? int.tryParse(json['budgetPesos'] ?? '0') ?? 0
                : (json['budgetPesos'] ?? 0) as int,
        nepBudgetPesos: json['nepBudgetPesos'] as int?,
        gaaBudgetPesos: json['gaaBudgetPesos'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'uacsCode': uacsCode,
        'agencyCode': agencyCode,
        'budget': budget,
        'budgetPesos': budgetPesos,
        'nepBudgetPesos': nepBudgetPesos,
        'gaaBudgetPesos': gaaBudgetPesos,
      };

  OperatingUnit copyWith({
    int? nepBudgetPesos,
    int? gaaBudgetPesos,
  }) {
    return OperatingUnit(
      code: code,
      description: description,
      uacsCode: uacsCode,
      agencyCode: agencyCode,
      budget: budget,
      budgetPesos: budgetPesos,
      nepBudgetPesos: nepBudgetPesos ?? this.nepBudgetPesos,
      gaaBudgetPesos: gaaBudgetPesos ?? this.gaaBudgetPesos,
    );
  }
}

class RegionBudget {
  final String code;
  final String description;
  final int budget;
  final int budgetPesos;

  RegionBudget({required this.code, required this.description, required this.budget, required this.budgetPesos});

  factory RegionBudget.fromJson(Map<String, dynamic> json) => RegionBudget(
    code: json['code'],
    description: json['description'],
    budget: json['budget'] is int
      ? json['budget'] as int
      : (json['budget'] ?? 0) is String
        ? int.tryParse(json['budget'] ?? '0') ?? 0
        : (json['budget'] ?? 0) as int,
    budgetPesos: json['budgetPesos'] is int
      ? json['budgetPesos'] as int
      : (json['budgetPesos'] ?? 0) is String
        ? int.tryParse(json['budgetPesos'] ?? '0') ?? 0
        : (json['budgetPesos'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() =>
      {'code': code, 'description': description, 'budget': budget, 'budgetPesos': budgetPesos};
}

class FundingSource {
  final String uacsCode;
  final String description;
  final String? fundClusterCode;
  final String? fundClusterDescription;
  final int budget;
  final int budgetPesos;

  FundingSource(
      {required this.uacsCode,
      required this.description,
      this.fundClusterCode,
      this.fundClusterDescription,
      required this.budget,
      required this.budgetPesos});

  factory FundingSource.fromJson(Map<String, dynamic> json) => FundingSource(
    uacsCode: json['uacsCode'],
    description: json['description'],
    fundClusterCode: json['fundClusterCode'] as String?,
    fundClusterDescription: json['fundClusterDescription'] as String?,
    budget: json['budget'] is int
      ? json['budget'] as int
      : (json['budget'] ?? 0) is String
        ? int.tryParse(json['budget'] ?? '0') ?? 0
        : (json['budget'] ?? 0) as int,
    budgetPesos: json['budgetPesos'] is int
      ? json['budgetPesos'] as int
      : (json['budgetPesos'] ?? 0) is String
        ? int.tryParse(json['budgetPesos'] ?? '0') ?? 0
        : (json['budgetPesos'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
        'uacsCode': uacsCode,
        'description': description,
        'fundClusterCode': fundClusterCode,
        'fundClusterDescription': fundClusterDescription,
        'budget': budget,
        'budgetPesos': budgetPesos
      };
}

class ExpenseCategory {
  final String code;
  final String description;
  final int budget;
  final int budgetPesos;

  ExpenseCategory({required this.code, required this.description, required this.budget, required this.budgetPesos});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => ExpenseCategory(
    code: json['code'],
    description: json['description'],
    budget: json['budget'] is int
      ? json['budget'] as int
      : (json['budget'] ?? 0) is String
        ? int.tryParse(json['budget'] ?? '0') ?? 0
        : (json['budget'] ?? 0) as int,
    budgetPesos: json['budgetPesos'] is int
      ? json['budgetPesos'] as int
      : (json['budgetPesos'] ?? 0) is String
        ? int.tryParse(json['budgetPesos'] ?? '0') ?? 0
        : (json['budgetPesos'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() =>
      {'code': code, 'description': description, 'budget': budget, 'budgetPesos': budgetPesos};
}

class Statistics {
  final int totalAgencies;
  final int totalOperatingUnits;
  final int totalRegions;
  final int totalFundingSources;
  final int totalExpenseCategories;
  final int totalProjects;

  Statistics(
      {required this.totalAgencies,
      required this.totalOperatingUnits,
      required this.totalRegions,
      required this.totalFundingSources,
      required this.totalExpenseCategories,
      required this.totalProjects});

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    totalAgencies: json['totalAgencies'] is int
      ? json['totalAgencies'] as int
      : (json['totalAgencies'] ?? 0) is String
        ? int.tryParse(json['totalAgencies'] ?? '0') ?? 0
        : (json['totalAgencies'] ?? 0) as int,
    totalOperatingUnits: json['totalOperatingUnits'] is int
      ? json['totalOperatingUnits'] as int
      : (json['totalOperatingUnits'] ?? 0) is String
        ? int.tryParse(json['totalOperatingUnits'] ?? '0') ?? 0
        : (json['totalOperatingUnits'] ?? 0) as int,
    totalRegions: json['totalRegions'] is int
      ? json['totalRegions'] as int
      : (json['totalRegions'] ?? 0) is String
        ? int.tryParse(json['totalRegions'] ?? '0') ?? 0
        : (json['totalRegions'] ?? 0) as int,
    totalFundingSources: json['totalFundingSources'] is int
      ? json['totalFundingSources'] as int
      : (json['totalFundingSources'] ?? 0) is String
        ? int.tryParse(json['totalFundingSources'] ?? '0') ?? 0
        : (json['totalFundingSources'] ?? 0) as int,
    totalExpenseCategories: json['totalExpenseCategories'] is int
      ? json['totalExpenseCategories'] as int
      : (json['totalExpenseCategories'] ?? 0) is String
        ? int.tryParse(json['totalExpenseCategories'] ?? '0') ?? 0
        : (json['totalExpenseCategories'] ?? 0) as int,
    totalProjects: json['totalProjects'] is int
      ? json['totalProjects'] as int
      : (json['totalProjects'] ?? 0) is String
        ? int.tryParse(json['totalProjects'] ?? '0') ?? 0
        : (json['totalProjects'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
        'totalAgencies': totalAgencies,
        'totalOperatingUnits': totalOperatingUnits,
        'totalRegions': totalRegions,
        'totalFundingSources': totalFundingSources,
        'totalExpenseCategories': totalExpenseCategories,
        'totalProjects': totalProjects
      };
}