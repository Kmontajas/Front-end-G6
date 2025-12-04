import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      if (Platform.isIOS) return 'http://localhost:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  // ===== BINS =====
  static Future<List<Map<String, dynamic>>> getBins() async {
    final res = await http.get(Uri.parse('$baseUrl/bins')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final data = (jsonDecode(res.body) as List).map((e) => e as Map<String, dynamic>).toList();
      return data;
    }
    throw Exception('Failed to fetch bins: ${res.statusCode}');
  }

  static Stream<List<Map<String, dynamic>>> streamBins({Duration interval = const Duration(seconds: 5)}) async* {
    while (true) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/bins')).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = (jsonDecode(res.body) as List).map((e) => e as Map<String, dynamic>).toList();
          yield data;
        } else {
          throw Exception('Failed to fetch bins: ${res.statusCode}');
        }
      } catch (e) {
        rethrow;
      }
      await Future.delayed(interval);
    }
  }

  static Future<Map<String, dynamic>> createBin(Map<String, dynamic> binData) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bins'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(binData),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create bin: ${res.statusCode}');
  }

  static Future<void> deleteBin(String binId) async {
    final res = await http.delete(Uri.parse('$baseUrl/bins/$binId')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Failed to delete bin: ${res.statusCode}');
  }

  // ===== ALERTS =====
  static Future<List<Map<String, dynamic>>> getAlerts() async {
    final res = await http.get(Uri.parse('$baseUrl/alerts')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final data = (jsonDecode(res.body) as List).map((e) => e as Map<String, dynamic>).toList();
      return data;
    }
    throw Exception('Failed to fetch alerts: ${res.statusCode}');
  }

  static Stream<List<Map<String, dynamic>>> streamAlerts({Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/alerts')).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = (jsonDecode(res.body) as List).map((e) => e as Map<String, dynamic>).toList();
          yield data;
        } else {
          throw Exception('Failed to fetch alerts: ${res.statusCode}');
        }
      } catch (e) {
        rethrow;
      }
      await Future.delayed(interval);
    }
  }
}
