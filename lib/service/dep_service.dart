import 'dart:convert';
import 'dart:io';
import 'package:budget_gov/model/dep_list.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<String?> getLocalNetworkIP() async {
  try {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
  } catch (e) {
    //
  }
  return null;
}

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

  http.Response response;

  try {
    String? ip;

    if (!kIsWeb) {
      ip = await getLocalNetworkIP();
    }

    final baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? 'http://192.168.18.193:3000/api/v1/departments/'
        : ip != null
            ? 'http://$ip:3000/api/v1/departments/'
            : 'http://localhost:3000/api/v1/departments/';

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    response = await http.get(uri);
    
  } catch (e) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final fallbackUri = Uri.parse('http://10.0.2.2:3000/api/v1/departments/')
          .replace(queryParameters: queryParams);
      response = await http.get(fallbackUri);
    } else {
      throw Exception('Failed to load departments: $e');
    }
  }

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (json) => ListOfAllDepartmets.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  } else {
    throw Exception('Failed to load departments: ${response.statusCode}');
  }
}
