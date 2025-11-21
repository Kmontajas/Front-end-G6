import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.37:3000"; // backend URL

  static Future<List<dynamic>> getBins() async {
    final res = await http.get(Uri.parse('$baseUrl/bins'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch bins');
  }

  static Future<List<dynamic>> getAlerts() async {
    final res = await http.get(Uri.parse('$baseUrl/alerts'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch alerts');
  }

  static Future<void> sendAlert(Map<String, dynamic> alert) async {
    final res = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(alert),
    );
    if (res.statusCode != 200) throw Exception('Failed to send alert');
  }
}
