import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_cache.dart';

class EuroleagueApiClient {
  EuroleagueApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(
    String url, {
    required String cacheKey,
    required Duration cacheTtl,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = ApiCache.instance.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.get(
      Uri.parse(url),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode} for $url');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    ApiCache.instance.set(cacheKey, data, cacheTtl);
    return data;
  }

  Future<List<dynamic>> getJsonList(
    String url, {
    required String cacheKey,
    required Duration cacheTtl,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = ApiCache.instance.get<List<dynamic>>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _client.get(
      Uri.parse(url),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode} for $url');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    ApiCache.instance.set(cacheKey, data, cacheTtl);
    return data;
  }
}
