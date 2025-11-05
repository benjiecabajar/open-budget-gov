import 'dart:convert';
import 'dart:io';
import 'package:budget_gov/model/list_of_departments.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<String> getLocalIpAddress() async {
  try {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type.name == 'IPv4' && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    debugPrint('Error getting IP: $e');
  }
  return 'localhost';
}

Future<List<ListOfAllDepartmets>> fetchListOfAllDepartments({
  required bool withBudget,
  required String year,
  required String type,
}) async {
  String baseUrl;

  if (defaultTargetPlatform == TargetPlatform.android) {
    final ip = await getLocalIpAddress();
    baseUrl = 'http://$ip:3000/api/v1/departments/';
  } else {
    baseUrl = 'http://localhost:3000/api/v1/departments/';
  }

  final queryParams = {
    'withBudget': withBudget.toString(),
    'year': year,
    'type': type,
  };

  final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

  debugPrint('Fetching from: $uri');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (json) => ListOfAllDepartmets.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  } else {
    debugPrint('Failed to load departments: ${response.statusCode}');
    throw Exception('Failed to load departments');
  }
}
