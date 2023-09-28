import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/models/passenger_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LoginService {
  final String baseUrl;

  LoginService(this.baseUrl);

  Future<Map<String, dynamic>> authenticate(User user) async {
    final url = Uri.parse('$baseUrl/api/users/authenticate');
    final headers = {
      'Content-Type': 'application/json',
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

  Future<User> register(User user) async {
    final url = Uri.parse('$baseUrl/api/users');
    final headers = {
      'Content-Type': 'application/json',
    };
    final response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'email': user.email,
          'username': user.username,
          'password': user.password,
          'isActive': true,
        }));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Return the user
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<void> completeRegister(Passenger passenger) async {
    final url = Uri.parse('$baseUrl/api/passengers');
    final headers = {
      'Content-Type': 'application/json',
    };
    final response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          'userId': passenger.userId,
          'firstName': passenger.firstName,
          'lastName': passenger.lastName,
          'lastName2': passenger.lastName2,
          'isActive': passenger.isActive,
          'phoneNumber': passenger.phoneNumber,
          'paymentMethodId': passenger.paymentMethodId // Always set to true
        }));

    if (response.statusCode != 200) {
      throw Exception('Registration failed');
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('user_id', userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
