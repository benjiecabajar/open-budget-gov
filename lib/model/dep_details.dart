class DepartmentDetails {
  final String code;
  final String description;
  final String abbreviation;
  final List<Agency> agencies;
  final List<dynamic> operatingUnitClasses;
  final Statistics statistics;

  DepartmentDetails({
    required this.code,
    required this.description,
    required this.abbreviation,
    required this.agencies,
    required this.operatingUnitClasses,
    required this.statistics,
  });

  factory DepartmentDetails.fromJson(Map<String, dynamic> json) {
    final agencyList = json['agencies'] as List<dynamic>;
    final agencies = agencyList
        .map((agencyJson) => Agency.fromJson(agencyJson as Map<String, dynamic>))
        .toList();

    return DepartmentDetails(
      code: json['code'] as String,
      description: json['description'] as String,
      abbreviation: json['abbreviation'] as String,
      agencies: agencies,
      operatingUnitClasses: json['operatingUnitClasses'] as List<dynamic>,
      statistics: Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'abbreviation': abbreviation,
      'agencies': agencies.map((agency) => agency.toJson()).toList(),
      'operatingUnitClasses': operatingUnitClasses,
      'statistics': statistics.toJson(),
    };
  }
}

class Agency {
  final String code;
  final String description;
  final String uacsCode;

  Agency({
    required this.code,
    required this.description,
    required this.uacsCode,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      code: json['code'] as String,
      description: json['description'] as String,
      uacsCode: json['uacsCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'uacsCode': uacsCode,
    };
  }
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

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalAgencies: json['totalAgencies'] as int,
      totalOperatingUnitClasses: json['totalOperatingUnitClasses'] as int,
      totalRegions: json['totalRegions'] as int,
      totalFundingSources: json['totalFundingSources'] as int,
      totalExpenseClassifications: json['totalExpenseClassifications'] as int,
      totalProjects: json['totalProjects'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAgencies': totalAgencies,
      'totalOperatingUnitClasses': totalOperatingUnitClasses,
      'totalRegions': totalRegions,
      'totalFundingSources': totalFundingSources,
      'totalExpenseClassifications': totalExpenseClassifications,
      'totalProjects': totalProjects,
    };
  }
}