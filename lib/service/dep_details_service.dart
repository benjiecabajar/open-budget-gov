import 'dart:convert';
import 'package:budget_gov/model/dep_details.dart';
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
  final cacheKey = 'department-details:$code:$year:${type ?? 'default'}';

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
  final nepOuMap = {for (var ou in nepDetails.operatingUnits) ou.uacsCode: ou};

  // Merge Agency budgets
  final combinedAgencies = gaaDetails.agencies.map((gaaAgency) {
    final nepAgency = nepAgencyMap[gaaAgency.uacsCode];
    return gaaAgency.copyWith(
      nepBudgetPesos: nepAgency?.budgetPesos,
      gaaBudgetPesos: gaaAgency.budgetPesos,
    );
  }).toList();

  // Merge Operating Unit budgets
  final combinedOperatingUnits = gaaDetails.operatingUnits.map((gaaOu) {
    final nepOu = nepOuMap[gaaOu.uacsCode];
    return gaaOu.copyWith(
      nepBudgetPesos: nepOu?.budgetPesos,
      gaaBudgetPesos: gaaOu.budgetPesos,
    );
  }).toList();

  // Return a new DepartmentDetails object with the merged lists
  // We use gaaDetails as the base for top-level info like totalBudget
  return DepartmentDetails(
    code: gaaDetails.code,
    description: gaaDetails.description,
    abbreviation: gaaDetails.abbreviation,
    totalBudget: gaaDetails.totalBudget,
    totalBudgetPesos: gaaDetails.totalBudgetPesos,
    agencies: combinedAgencies, // Use merged agencies
    operatingUnits: combinedOperatingUnits, // Use merged operating units
    regions: gaaDetails.regions,
    fundingSources: gaaDetails.fundingSources,
    expenseCategories: gaaDetails.expenseCategories,
    statistics: gaaDetails.statistics,
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