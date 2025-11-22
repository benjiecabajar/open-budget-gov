import 'dart:convert';
import 'package:budget_gov/model/dep_details.dart';
import 'package:budget_gov/model/funds_sources.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_gov/service/dep_service.dart';

Future<DepartmentDetails> fetchDepartmentDetails({
  required String code,
  required String year,
  String? type, // Keep this for fetching individual types
  bool combineBudgets = false, // Add a flag to trigger the new logic
}) async {
  if (combineBudgets) {
    return _fetchAndCombineBudgets(code, year);
  }

  final queryParameters = {'year': year};
  if (type != null) queryParameters['type'] = type; // Use the provided type
  final prefs = await SharedPreferences.getInstance(); 
  final cacheKey = 'department-details:$code:$year:${type ?? 'NEP'}'; // Consistent cache key

  final cachedResponse = prefs.getString(cacheKey);
  if (cachedResponse != null) {
    try {
      final decoded = jsonDecode(cachedResponse);
      return DepartmentDetails.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      // If parsing fails, proceed to fetch from network
    }
  }

  // Default to fetching from the API if not combining
  return _fetchFromApi(code, year, type, prefs, cacheKey);
}

Future<DepartmentDetails> _fetchAndCombineBudgets(String code, String year) async {
  // Fetch both NEP and GAA details concurrently
  final List<DepartmentDetails> results = await Future.wait([
    fetchDepartmentDetails(code: code, year: year, type: 'NEP'),
    fetchDepartmentDetails(code: code, year: year, type: 'GAA'),
  ]);
  final nepDetails = results[0];
  final gaaDetails = results[1];

  // Create maps for quick lookups
  final nepAgencyMap = {for (var agency in nepDetails.agencies) agency.uacsCode: agency};
  final nepFundingSourceMap = {for (var fs in nepDetails.fundingSources) fs.uacsCode: fs};
  final nepOuMap = {for (var ou in nepDetails.operatingUnitClasses) ou.code: ou};
  final nepRegionMap = {for (var region in nepDetails.regions) region.code: region};

  // Merge Agency budgets
  final combinedAgencies = gaaDetails.agencies.map((gaaAgency) {
    final nepAgency = nepAgencyMap[gaaAgency.uacsCode];
    return Agency(
      code: gaaAgency.code, description: gaaAgency.description, uacsCode: gaaAgency.uacsCode,
      nep: nepAgency?.nep ?? Money(amount: 0, amountPesos: 0),
      gaa: gaaAgency.gaa,
    );
  }).toList();

  // Merge Operating Unit budgets
  final combinedOperatingUnits = gaaDetails.operatingUnitClasses.map((gaaOu) {
    final nepOu = nepOuMap[gaaOu.code];
    return OperatingUnitClass(
      code: gaaOu.code, description: gaaOu.description, status: gaaOu.status, operatingUnitCount: gaaOu.operatingUnitCount,
      nep: nepOu?.nep ?? Money(amount: 0, amountPesos: 0), // Use NEP budget from NEP details if available, otherwise 0
      gaa: gaaOu.gaa, // Use GAA budget from GAA details
    );
  }).toList();

  // Merge Region budgets
  final combinedRegions = gaaDetails.regions.map((gaaRegion) {
    final nepRegion = nepRegionMap[gaaRegion.code];
    return RegionBudget(
      code: gaaRegion.code,
      description: gaaRegion.description,
      nep: nepRegion?.nep ?? Money(amount: 0, amountPesos: 0),
      gaa: gaaRegion.gaa,
    );
  }).toList();

  // Merge Funding Sources budgets
  final combinedFundingSources = gaaDetails.fundingSources.map((gaaFs) {
    final nepFs = nepFundingSourceMap[gaaFs.uacsCode];
    return FundSource(
      uacsCode: gaaFs.uacsCode,
      description: gaaFs.description,
      clusterCode: gaaFs.clusterCode,
      clusterDescription: gaaFs.clusterDescription,
      totalBudget: nepFs?.totalBudget ?? 0, // NEP budget
      totalBudgetPesos: gaaFs.totalBudgetPesos, // GAA budget
    );
  }).toList();

  // Manually calculate the difference and percentage change
  final nepAmountPesos = nepDetails.budgetComparison.nep.amountPesos;
  final gaaAmountPesos = gaaDetails.budgetComparison.gaa.amountPesos;
  final differenceAmountPesos = gaaAmountPesos - nepAmountPesos;
  double percentChange = 0.0;
  if (nepAmountPesos != 0) {
    percentChange = (differenceAmountPesos / nepAmountPesos) * 100;
  }

  // Return a new DepartmentDetails object with the merged lists
  // We use gaaDetails as the base for top-level info like totalBudget
  return DepartmentDetails(
    code: gaaDetails.code,
    description: gaaDetails.description,
    totalBudget: gaaDetails.totalBudget, // Use GAA total budget for the main view
    totalBudgetPesos: gaaDetails.totalBudgetPesos, // Use GAA total budget pesos
    percentOfTotalBudget: nepDetails.percentOfTotalBudget,
    totalBudgetGaa: gaaDetails.totalBudgetGaa,
    totalBudgetGaaPesos: gaaDetails.totalBudgetGaaPesos,
    percentDifferenceNepGaa: gaaDetails.percentDifferenceNepGaa,
    totalAgencies: gaaDetails.totalAgencies,
    totalProjects: gaaDetails.totalProjects,
    totalRegions: gaaDetails.totalRegions,
    agencies: combinedAgencies, // Use merged agencies
    operatingUnitClasses: combinedOperatingUnits,
    regions: combinedRegions, // Use merged regions
    projects: gaaDetails.projects, // Assuming projects are the same for NEP and GAA
    fundingSources: combinedFundingSources, // Use merged funding sources
    expenseClassifications:
        gaaDetails.expenseClassifications, 
    statistics: gaaDetails.statistics, 
    budgetComparison: BudgetComparison(
      nep: nepDetails.budgetComparison.nep,
      gaa: gaaDetails.budgetComparison.gaa,
      difference: Difference(
        amount: gaaDetails.totalBudgetGaa - nepDetails.totalBudget,
        amountPesos: differenceAmountPesos,
        percentChange: percentChange,
      ),
    ),
  );
}

Future<DepartmentDetails> _fetchFromApi(String code, String year, String? type, SharedPreferences prefs, String cacheKey) async {
  final path = '/api/v1/departments/$code/details';

  http.Response response;

  try {
    final ip = await getLocalNetworkIP();
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '192.168.18.193'
        : (ip ?? 'localhost');
    final queryParameters = {
      'year': year,
      if (type != null) 'type': type,
    };
    final uri = Uri.http('$host:3000', path, queryParameters);
    response = await http.get(uri);
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final queryParameters = {'year': year, if (type != null) 'type': type};
      final fallbackUri = Uri.http('10.0.2.2:3000', path, queryParameters);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load department details: $e');
    }
  }

  if (response.statusCode == 200) {
    // Cache the successful response 
    try {
      debugPrint('API Response for department details ($code, $year): ${response.body}'); // Log raw API response
      await prefs.setString(cacheKey, response.body);
    } catch (e) {
      // Ignore caching errors
    }
    return DepartmentDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load department details: ${response.statusCode}');
  }
}