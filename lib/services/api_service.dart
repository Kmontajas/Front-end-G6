import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  // Dynamic baseUrl: works on web, Android emulator, and desktop
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      if (Platform.isIOS) return 'http://localhost:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  // Simple GET for bins
  static Future<List<dynamic>> getBins() async {
    final res = await http.get(Uri.parse('$baseUrl/bins')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    throw Exception('Failed to fetch bins: ${res.statusCode}');
  }

  // Polling stream for bins (works on web and mobile)
  static Stream<List<dynamic>> streamBins({Duration interval = const Duration(seconds: 5)}) async* {
    while (true) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/bins')).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List<dynamic>;
          yield data;
        } else {
          throw Exception('Failed to fetch bins: ${res.statusCode}');
        }
      } catch (e) {
        // Pass error to listeners; UI code handles showing cached data on errors
        rethrow;
      }

      await Future.delayed(interval);
    }
  }

  // Optional convenience methods used by the UI
  static Future<dynamic> createBin(Map<String, dynamic> binData) async {
    final res = await http.post(Uri.parse('$baseUrl/bins'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(binData)).timeout(const Duration(seconds: 10));
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to create bin: ${res.statusCode}');
  }

  static Future<void> deleteBin(String binId) async {
    final res = await http.delete(Uri.parse('$baseUrl/bins/$binId')).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Failed to delete bin: ${res.statusCode}');
  }
}
