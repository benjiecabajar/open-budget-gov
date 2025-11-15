import 'dart:convert';
import 'package:budget_gov/model/details_of_departments.dart';
import 'package:budget_gov/service/departments.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<DepartmentDetails> fetchDepartmentDetails({
  required String code,
  required String year,
}) async {
  final queryParams = {
    'year': year,
  };

  http.Response response;
  final path = '/api/v1/departments/$code/details?year=$year';

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

    final uri = Uri.parse(baseUrl + path).replace(queryParameters: queryParams);
    response = await http.get(uri);
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.parse('http://10.0.2.2:3000$path')
          .replace(queryParameters: queryParams);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load department details: $e');
    }
  }

  if (response.statusCode == 200) {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return DepartmentDetails.fromJson(data);
  } else {
    throw Exception(
        'Failed to load department details: ${response.statusCode}');
  }
}