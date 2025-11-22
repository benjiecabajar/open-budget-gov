import 'dart:convert';
import 'package:budget_gov/model/reg_budget.dart';
import 'package:budget_gov/service/dep_service.dart'; // For getLocalNetworkIP
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Fetches a list of regional budget summaries from the API.
///
/// This function makes a network request to the `/api/v1/regions/allocation`
/// endpoint and parses the resulting JSON into a list of [RegionalBudgetSummary] objects.
Future<List<RegionalBudgetSummary>> fetchRegionalBudgetSummaries({
  required String year,
  required String type,
}) async {
  http.Response response;
  const path = '/api/v1/regions/allocation';
  final queryParameters = {
    'year': year,
    'type': type,
  };

  try {
    String? ip;

    // Do not attempt to get local IP on web platform
    if (!kIsWeb) {
      ip = await getLocalNetworkIP();
    }

    // Determine the base URL based on the platform and available IP
    final baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? 'http://192.168.18.193:3000'
        : ip != null
            ? 'http://$ip:3000'
            : 'http://localhost:3000';

    final uri = Uri.parse(baseUrl).replace(path: path, queryParameters: queryParameters);
    response = await http.get(uri);
  } catch (e) {
    // Fallback for Android emulator if the primary connection fails
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.parse('http://10.0.2.2:3000').replace(path: path, queryParameters: queryParameters);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load regional budget summaries: $e');
    }
  }

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => RegionalBudgetSummary.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load regional budget summaries: ${response.statusCode}');
  }
}