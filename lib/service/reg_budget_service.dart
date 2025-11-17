import 'dart:convert';
import 'package:budget_gov/model/reg_names.dart';
import 'package:budget_gov/service/dep_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<RegionalBudget>> fetchRegionalBudgets({
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

    if (!kIsWeb) {
      ip = await getLocalNetworkIP();
    }

    final baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? 'http://192.168.18.193:3000'
        : ip != null
            ? 'http://$ip:3000'
            : 'http://localhost:3000';

    final uri = Uri.parse(baseUrl).replace(path: path, queryParameters: queryParameters);
    response = await http.get(uri);
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.parse('http://10.0.2.2:3000').replace(path: path, queryParameters: queryParameters);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load regional budgets: $e');
    }
  }

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => RegionalBudget.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Failed to load regional budgets: ${response.statusCode}');
  }
}