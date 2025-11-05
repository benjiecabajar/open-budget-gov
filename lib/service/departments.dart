import 'dart:convert';
import 'package:budget_gov/model/list_of_departments.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<ListOfAllDepartmets>> fetchListOfAllDepartments({
  required bool withBudget,
  required String year,
  required String type,
}) async {
  final queryParams = {
    'withBudget': withBudget.toString(),
    'year': year,
    'type': type,
  };

  final baseUrl = defaultTargetPlatform == TargetPlatform.android
      ? 'http://192.168.18.193:3000/api/v1/departments/' //My Phone ni sir
      : 'http://localhost:3000/api/v1/departments/';

  final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (json) => ListOfAllDepartmets.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  } else {
    throw Exception('Failed to load departments');
  }
}
