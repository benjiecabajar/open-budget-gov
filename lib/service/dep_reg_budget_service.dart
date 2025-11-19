import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:budget_gov/model/dep_reg_budget.dart';
import 'package:flutter/foundation.dart';
import 'package:budget_gov/service/dep_service.dart';

Future<DepartmentRegionalBudget> fetchDepartmentRegionalBudget({ 
  required String year,
  required String type,
  required String departmentCode,
  required String regionCode,
}) async {
  final queryParameters = {
    'year': year,
    'type': type,
    'department': departmentCode,
    'region': regionCode,
  };

  http.Response response;

  try {
    String? ip;

    if (!kIsWeb) {
      ip = await getLocalNetworkIP();
    }

    final baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? 'http://192.168.18.193:3000/api/v1/budget/total'
        : ip != null
            ? 'http://$ip:3000/api/v1/budget/total'
            : 'http://localhost:3000/api/v1/budget/total';

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
    response = await http.get(uri);
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.parse('http://10.0.2.2:3000/api/v1/budget/total').replace(queryParameters: queryParameters);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load department regional budget for region $regionCode: $e');
    }
  }

  if (response.statusCode == 200) {
    return DepartmentRegionalBudget.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load department regional budget for region $regionCode');
  }
}