import 'dart:convert';
import 'package:budget_gov/model/operating_units.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_gov/service/dep_service.dart';

Future<OperatingUnitDetails> fetchOperatingUnitByCode({
  required String code,
  required String year,
  String? type,
  bool withBudget = true,
}) async {
  final queryParameters = {
    'year': year,
    'withBudget': withBudget.toString(),
    if (type != null) 'type': type,
  };

  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'operating-unit:$code:$year:${type ?? 'default'}';

  // Check cache first
  final cachedResponse = prefs.getString(cacheKey);
  if (cachedResponse != null) {
    try {
      final decoded = jsonDecode(cachedResponse);
      return OperatingUnitDetails.fromJson(decoded as Map<String, dynamic>);
    } catch (e) {
      // If parsing fails, proceed to fetch from network
    }
  }

  // Fetch from API if not in cache or if cache is invalid
  return _fetchFromApi(code, queryParameters, prefs, cacheKey);
}

Future<OperatingUnitDetails> _fetchFromApi(
  String code,
  Map<String, String> queryParameters,
  SharedPreferences prefs,
  String cacheKey,
) async {
  final path = '/api/v1/organizations/$code';
  http.Response response;

  try {
    final ip = await getLocalNetworkIP();
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '192.168.18.193'
        : (ip ?? 'localhost');
    final uri = Uri.http('$host:3000', path, queryParameters);
    response = await http.get(uri);
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.http('10.0.2.2:3000', path, queryParameters);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load operating unit details: $e');
    }
  }

  if (response.statusCode == 200) {
    // Cache the successful response
    await prefs.setString(cacheKey, response.body);
    return OperatingUnitDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Failed to load operating unit details: ${response.statusCode}');
  }
}