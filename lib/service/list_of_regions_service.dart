import 'dart:convert';
import 'package:budget_gov/model/list_of_regions.dart';
import 'package:budget_gov/service/departments.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<ListOfRegions>> fetchListOfRegions({
  required String year,
  required String type,
}) async {
  http.Response response;
  const path = '/api/v1/regions';
  final queryParameters = {
    'withBudget': 'true',
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
      try {
        final fallbackUri = Uri.parse('http://10.0.2.2:3000').replace(path: path, queryParameters: queryParameters);
        response = await http.get(fallbackUri);
      } catch (fallbackError) {
        throw Exception('Failed to load list of regions: $fallbackError');
      }
    } else {
      throw Exception('Failed to load list of regions: $e');
    }
  }

  if (response.statusCode == 200) {
    try {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => ListOfRegions.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to parse regions data: $e');
    }
  } else {
    throw Exception('Failed to load list of regions: Status ${response.statusCode} - ${response.body}');
  }
}