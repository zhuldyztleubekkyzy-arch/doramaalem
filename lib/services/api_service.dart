import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dorama.dart';

class ApiService {
        // http://10.0.2.2:3000/api
        // http://localhost:3000/api
        // http://192.168.0.1:3000/api
  static const String baseUrl = 'http://localhost:3000/api';

  // Get auth token from Firebase
  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // Make authenticated request
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Белгісіз HTTP әдісі: $method');
    }
  }

  // Get all doramas
  Future<List<Dorama>> getDoramas() async {
    try {
      final response = await _makeRequest('GET', '/doramas');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dorama.fromJson(json)).toList();
      } else {
        throw Exception('Дорамаларды алу қатесі: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API қатесі: ${e.toString()}');
    }
  }

  // Get dorama by ID
  Future<Dorama> getDoramaById(int id) async {
    try {
      final response = await _makeRequest('GET', '/doramas/$id');
      if (response.statusCode == 200) {
        return Dorama.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Дораманы алу қатесі: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API қатесі: ${e.toString()}');
    }
  }

  // Search doramas
  Future<List<Dorama>> searchDoramas(String query) async {
    try {
      final response = await _makeRequest('GET', '/doramas/search?q=$query');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dorama.fromJson(json)).toList();
      } else {
        throw Exception('Іздеу қатесі: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API қатесі: ${e.toString()}');
    }
  }
}

