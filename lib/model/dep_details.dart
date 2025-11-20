import 'package:budget_gov/model/funds_sources.dart';
class DepartmentDetails {
  final String code;
  final String description;
  final int totalBudget;
  final int totalBudgetPesos;
  final double percentOfTotalBudget;
  final int totalBudgetGaa;
  final int totalBudgetGaaPesos;
  final double percentDifferenceNepGaa;
  final int totalAgencies;
  final int totalProjects;
  final int totalRegions;
  final List<Agency> agencies;
  final List<OperatingUnitClass> operatingUnitClasses;
  final Statistics statistics;
  final BudgetComparison budgetComparison;
  final List<RegionBudget> regions;
  final List<ProjectItem> projects; 
  final List<FundSource> fundingSources;
  final List<ListItem> expenseClassifications;

  DepartmentDetails({
    required this.code,
    required this.description,
    required this.totalBudget,
    required this.totalBudgetPesos,
    required this.percentOfTotalBudget,
    required this.totalBudgetGaa,
    required this.totalBudgetGaaPesos,
    required this.percentDifferenceNepGaa,
    required this.totalAgencies,
    required this.totalProjects,
    required this.totalRegions,
    required this.agencies,
    required this.operatingUnitClasses,
    required this.statistics,
    required this.budgetComparison,
    required this.regions,
    required this.projects,
    required this.fundingSources,
    required this.expenseClassifications, // Keep this as ListItem for now
  });

  factory DepartmentDetails.fromJson(Map<String, dynamic> json) =>
      DepartmentDetails(
        code: json['code'] as String,
        description: json['description'] as String,
        totalBudget: json['totalBudget'] as int? ?? 0,
        totalBudgetPesos: json['totalBudgetPesos'] as int? ?? 0,

        percentOfTotalBudget:
            (json['percentOfTotalBudget'] as num?)?.toDouble() ?? 0.0,
        totalBudgetGaa: json['totalBudgetGaa'] as int? ?? 0,
        totalBudgetGaaPesos: json['totalBudgetGaaPesos'] as int? ?? 0,

        percentDifferenceNepGaa:
            (json['percentDifferenceNepGaa'] as num?)?.toDouble() ?? 0.0,
        totalAgencies: json['totalAgencies'] as int? ?? 0,
        totalProjects: json['totalProjects'] as int? ?? 0,
        totalRegions: json['totalRegions'] as int? ?? 0,
        agencies: (json['agencies'] as List<dynamic>? ?? [])
            .map((e) => Agency.fromJson(e as Map<String, dynamic>))
            .toList(),

        operatingUnitClasses:
            (json['operatingUnitClasses'] as List<dynamic>? ?? [])
                .map((e) =>
                    OperatingUnitClass.fromJson(e as Map<String, dynamic>))
                .toList(),

        statistics: Statistics.fromJson(
            json['statistics'] as Map<String, dynamic>? ?? {}),

        budgetComparison: BudgetComparison.fromJson(
            json['budgetComparison'] as Map<String, dynamic>? ?? {}),

        regions: (json['regions'] as List<dynamic>? ?? [])
            .map((e) => RegionBudget.fromJson(e as Map<String, dynamic>))
            .toList(),

        projects: (json['projects'] as List<dynamic>? ?? [])
            .map((e) => ProjectItem.fromJson(e as Map<String, dynamic>))
            .toList(),

        fundingSources: (json['fundingSources'] as List<dynamic>? ?? [])
            .map((e) => FundSource.fromJson(e as Map<String, dynamic>))
            .toList(),
            
        expenseClassifications:
            (json['expenseClassifications'] as List<dynamic>? ?? [])
                .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'totalBudget': totalBudget,
        'totalBudgetPesos': totalBudgetPesos,
        'percentOfTotalBudget': percentOfTotalBudget,
        'totalBudgetGaa': totalBudgetGaa,
        'totalBudgetGaaPesos': totalBudgetGaaPesos,
        'percentDifferenceNepGaa': percentDifferenceNepGaa,
        'totalAgencies': totalAgencies,
        'totalProjects': totalProjects,
        'totalRegions': totalRegions,
        'agencies': agencies.map((a) => a.toJson()).toList(),
        'operatingUnitClasses':
            operatingUnitClasses.map((o) => o.toJson()).toList(),
        'statistics': statistics.toJson(),
        'budgetComparison': budgetComparison.toJson(),
        'regions': regions.map((r) => r.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'fundingSources': fundingSources.map((f) => f.toJson()).toList(),
        'expenseClassifications':
            expenseClassifications.map((e) => e.toJson()).toList(),
      };
}

class Agency {
  final String code;
  final String description;
  final String? uacsCode;
  final Money nep;
  final Money gaa;

  Agency({
    required this.code,
    required this.description,
    this.uacsCode,
    required this.nep,
    required this.gaa,
  });

  factory Agency.fromJson(Map<String, dynamic> json) => Agency(
        code: json['code'] as String,
        description: json['description'] as String,
        uacsCode: json['uacsCode'] as String?,
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        if (uacsCode != null) 'uacsCode': uacsCode,
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
      };
}

class ListItem {
  final String code;
  final String description;
  final Money nep;
  final Money gaa;
  final String? uacsCode;
 
  ListItem({
    required this.code, 
    required this.description,
    required this.nep,
    required this.gaa,
    this.uacsCode,
  });
  
  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        code: json['code'] as String? ?? 'N/A',
        description: json['description'] as String? ?? 'No description',
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
        uacsCode: json['uacsCode'] as String?,
      );
      

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
        'uacsCode': uacsCode,
      };
}

class Money {
  final num amount;
  final num amountPesos;

  Money({required this.amount, required this.amountPesos});

  factory Money.fromJson(Map<String, dynamic> json) => Money(
        amount: json['amount'] ?? 0,
        amountPesos: json['amountPesos'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'amountPesos': amountPesos,
      };
}

class OperatingUnitClass {
  final String code;
  final String description;
  final String? status;
  final int? operatingUnitCount;
  final Money nep;
  final Money gaa;

  OperatingUnitClass({
    required this.code,
    required this.description,
    this.status,
    this.operatingUnitCount,
    required this.nep,
    required this.gaa,
  });

  factory OperatingUnitClass.fromJson(Map<String, dynamic> json) =>
      OperatingUnitClass(
        code: json['code'] as String,
        description: json['description'] as String,
        status: json['status'] as String?,
        operatingUnitCount: json['operatingUnitCount'] as int?,
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        if (status != null) 'status': status,
        if (operatingUnitCount != null)
          'operatingUnitCount': operatingUnitCount,
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
      };
}

class Statistics {
  final int totalAgencies;
  final int totalOperatingUnitClasses;
  final int totalRegions;
  final int totalFundingSources;
  final int totalExpenseClassifications;
  final int totalProjects;

  Statistics({
    required this.totalAgencies,
    required this.totalOperatingUnitClasses,
    required this.totalRegions,
    required this.totalFundingSources,
    required this.totalExpenseClassifications,
    required this.totalProjects,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        totalAgencies: json['totalAgencies'] ?? 0,
        totalOperatingUnitClasses: json['totalOperatingUnitClasses'] ?? 0,
        totalRegions: json['totalRegions'] ?? 0,
        totalFundingSources: json['totalFundingSources'] ?? 0,
        totalExpenseClassifications: json['totalExpenseClassifications'] ?? 0,
        totalProjects: json['totalProjects'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalAgencies': totalAgencies,
        'totalOperatingUnitClasses': totalOperatingUnitClasses,
        'totalRegions': totalRegions,
        'totalFundingSources': totalFundingSources,
        'totalExpenseClassifications': totalExpenseClassifications,
        'totalProjects': totalProjects,
      };
}

class BudgetComparison {
  final Money nep;
  final Money gaa;
  final Difference difference;

  BudgetComparison({
    required this.nep,
    required this.gaa,
    required this.difference,
  });

  factory BudgetComparison.fromJson(Map<String, dynamic> json) =>
      BudgetComparison(
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
        difference: Difference.fromJson(
            json['difference'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
        'difference': difference.toJson(),
      };
}

class Difference {
  final num amount;
  final num amountPesos;
  final num? percentChange;
  final String? status;

  Difference({
    required this.amount,
    required this.amountPesos,
    this.percentChange,
    this.status,
  });

  factory Difference.fromJson(Map<String, dynamic> json) => Difference(
        amount: json['amount'] ?? 0,
        amountPesos: json['amountPesos'] ?? 0,
        percentChange: json['percentChange'],
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'amountPesos': amountPesos,
        if (percentChange != null) 'percentChange': percentChange,
        if (status != null) 'status': status,
      };
}

class RegionBudget {
  final String code;
  final String? description;
  final Money nep;
  final Money gaa;
  final num? difference;
  final num? differencePesos;
  final num? percentChange;

  RegionBudget({
    required this.code,
    this.description,
    required this.nep,
    required this.gaa,
    this.difference,
    this.differencePesos,
    this.percentChange,
  });

  factory RegionBudget.fromJson(Map<String, dynamic> json) => RegionBudget(
        code: json['code'] as String,
        description: json['description'] as String?,
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
        difference: json['difference'],
        differencePesos: json['differencePesos'],
        percentChange: json['percentChange'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        if (description != null) 'description': description,
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
        if (difference != null) 'difference': difference,
        if (differencePesos != null) 'differencePesos': differencePesos,
        if (percentChange != null) 'percentChange': percentChange,
      };
}

class ProjectItem {
  final String? prexcFpapId;
  final String description;
  final Money nep;
  final Money gaa;

  ProjectItem({
    this.prexcFpapId,
    required this.description,
    required this.nep,
    required this.gaa,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
        prexcFpapId: json['prexcFpapId'] as String?,
        description: json['description'] as String? ?? '',
        nep: Money.fromJson(json['nep'] as Map<String, dynamic>? ?? {}),
        gaa: Money.fromJson(json['gaa'] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        if (prexcFpapId != null) 'prexcFpapId': prexcFpapId,
        'description': description,
        'nep': nep.toJson(),
        'gaa': gaa.toJson(),
      };
}
