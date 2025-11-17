class FundingSourcesResponse {
  final List<FundingFund> data;
  final Meta meta;

  FundingSourcesResponse({required this.data, required this.meta});

  factory FundingSourcesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    return FundingSourcesResponse(
      data: dataList
          .map((e) => FundingFund.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class FundingFund {
  final String code;
  final String description;
  final List<FundingSource> fundingSources;

  FundingFund(
      {required this.code, required this.description, required this.fundingSources});

  factory FundingFund.fromJson(Map<String, dynamic> json) {
    final fundingSourcesList = json['fundingSources'] as List<dynamic>;
    return FundingFund(
      code: json['code'] as String,
      description: json['description'] as String,
      fundingSources: fundingSourcesList
          .map((e) => FundingSource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'fundingSources': fundingSources.map((e) => e.toJson()).toList(),
    };
  }
}

class FundingSource {
  final FundCategory? fundCategory;
  final FinancingSource financingSource;
  final String uacsCode;
  final String description;
  final Authorization authorization;
  final String financingSourceCode;
  final String? fundCategoryCode;
  final String fundClusterCode;
  final String authorizationCode; // This holds the amount

  FundingSource({
    this.fundCategory,
    required this.financingSource,
    required this.uacsCode,
    required this.description,
    required this.authorization,
    required this.financingSourceCode,
    this.fundCategoryCode,
    required this.fundClusterCode,
    required this.authorizationCode,
  });

  factory FundingSource.fromJson(Map<String, dynamic> json) {
    return FundingSource(
      fundCategory: json['fundCategory'] != null
          ? FundCategory.fromJson(json['fundCategory'] as Map<String, dynamic>)
          : null,
      financingSource:
          FinancingSource.fromJson(json['financingSource'] as Map<String, dynamic>),
      uacsCode: json['uacsCode'] as String,
      description: json['description'] as String,
      authorization:
          Authorization.fromJson(json['authorization'] as Map<String, dynamic>),
      financingSourceCode: json['financingSourceCode'] as String,
      fundCategoryCode: json['fundCategoryCode'] as String?,
      fundClusterCode: json['fundClusterCode'] as String,
      authorizationCode: json['authorizationCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fundCategory': fundCategory?.toJson(),
      'financingSource': financingSource.toJson(),
      'uacsCode': uacsCode,
      'description': description,
      'authorization': authorization.toJson(),
      'financingSourceCode': financingSourceCode,
      'fundCategoryCode': fundCategoryCode,
      'fundClusterCode': fundClusterCode,
      'authorizationCode': authorizationCode,
    };
  }
}

class FundCategory {
  final String? uacsCode;
  final String? description;

  FundCategory({this.uacsCode, this.description});

  factory FundCategory.fromJson(Map<String, dynamic> json) {
    return FundCategory(
      uacsCode: json['uacsCode'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uacsCode': uacsCode,
      'description': description,
    };
  }
}

class FinancingSource {
  final String description;
  final String code;

  FinancingSource({required this.description, required this.code});

  factory FinancingSource.fromJson(Map<String, dynamic> json) {
    return FinancingSource(
      description: json['description'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'code': code,
    };
  }
}

class Authorization {
  final String description;
  final String code;

  Authorization({required this.description, required this.code});

  factory Authorization.fromJson(Map<String, dynamic> json) {
    return Authorization(
      description: json['description'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'code': code,
    };
  }
}

class Meta {
  final int totalFundClusters;
  final int totalFundingSources;
  final int totalFinancingSources;
  final int totalAuthorizations;

  Meta({
    required this.totalFundClusters,
    required this.totalFundingSources,
    required this.totalFinancingSources,
    required this.totalAuthorizations,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      totalFundClusters: json['totalFundClusters'] as int,
      totalFundingSources: json['totalFundingSources'] as int,
      totalFinancingSources: json['totalFinancingSources'] as int,
      totalAuthorizations: json['totalAuthorizations'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFundClusters': totalFundClusters,
      'totalFundingSources': totalFundingSources,
      'totalFinancingSources': totalFinancingSources,
      'totalAuthorizations': totalAuthorizations,
    };
  }
}