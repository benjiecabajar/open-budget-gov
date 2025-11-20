import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_gov/model/funds_sources.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<String?> getLocalNetworkIP() async {
  if (!kIsWeb) {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }
  return null;
}

Future<FundSource> fetchFundSourceDetails({
  required String code,
  required String year,
  String withBudget = 'true',
  String type = '',
}) async {
  final queryParameters = {
    'year': year,
    'withBudget': withBudget,
    if (type.isNotEmpty) 'type': type, // Ensure type is passed in the query
  };
  final path = '/api/v1/funding-sources/$code';
  // Use SharedPreferences to cache fund source responses per code/year/type/withBudget
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'fundsource:$code:$year:$type:$withBudget';

  // If cached, return cached value immediately to speed up UI
  final cached = prefs.getString(cacheKey);
  if (cached != null) {
    try {
      final Map<String, dynamic> json = jsonDecode(cached) as Map<String, dynamic>;
      return FundSource.fromJson(json);
    } catch (_) {
      // ignore cache parse errors and fall through to network fetch
    }
  }

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
      throw Exception('Failed to load fund source details: $e');
    }
  }

  if (response.statusCode == 200) {
    // cache the raw JSON response for future quick loads
    try {
      await prefs.setString(cacheKey, response.body);
    } catch (_) {
      // ignore caching errors
    }
    return FundSource.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load fund source details: ${response.statusCode}');
  }
}