import 'dart:convert';
import 'package:budget_gov/model/exp.dart';
import 'package:budget_gov/service/dep_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<Expense>> fetchExpenseCategories({
  required String year,
  String? departmentCode,
}) async {
  final path = '/api/v1/expense-categories';
  final queryParameters = {
    'year': year,
    if (departmentCode != null) 'department': departmentCode,
  };

  http.Response response;

  try {
    String? ip;

    if (!kIsWeb) {
      ip = await getLocalNetworkIP();
    }

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
      throw Exception('Failed to load expense categories: $e');
    }
  }

  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to parse expense categories: $e');
    }
  } else {
    throw Exception('Failed to load expense categories: Status ${response.statusCode}');
  }
}
