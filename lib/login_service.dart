import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'user_model.dart';

class LoginService {
  final String baseUrl;

  LoginService(this.baseUrl);

  Future<Map<String, dynamic>> authenticate(User user) async {
    final url = Uri.parse('$baseUrl/api/users/authenticate');
    final headers = {
      'Content-Type': 'application/json', // Set the correct content type
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'email': user.email, 'password': user.password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Authentication failed');
    }
  }

  Future<void> register(User user) async {
    final url = Uri.parse('$baseUrl/api/users');
    final headers = {
      'Content-Type': 'application/json', // Set the correct content type
    };
    final response = await http.post(url, headers: headers, body: {
      'email': user.email,
      'username': user.username,
      'password': user.password,
      'isActive': true, // Always set to true
    });

    if (response.statusCode != 200) {
      throw Exception('Registration failed');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
