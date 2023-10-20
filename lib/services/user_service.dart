import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class UserService {
  static Future<User?> authenticate(User user) async {
    final url = Uri.parse('$kDeployedUrl/api/users/authenticate');
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
      'Content-Type': 'application/json; charset=UTF-8'
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(user.toJsonLogin()),
    );

    if (response.statusCode == 200) {
      return User.fromJsonLogin(jsonDecode(response.body));
    } else {
      throw Exception('Authentication failed');
    }
  }

  static Future<User> register(User user) async {
    final url = Uri.parse('$kDeployedUrl/api/users');
    final headers = {
      'Content-Type': 'application/json',
    };
    final response =
        await http.post(url, headers: headers, body: jsonEncode(user.toJson()));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Return the user
    } else {
      throw Exception('Registration failed');
    }
  }

  static Future<User?> checkEmail(String email) async {
    final url = Uri.parse('$kDeployedUrl/api/users/get-by-email');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'email': email,
        },
      ),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<User?> sendResetPasswordMail(String email) async {
    final url = Uri.parse('$kDeployedUrl/api/users/send-reset-password-email');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'email': email,
        },
      ),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<User?> updateUser(User user) async {
    final url = Uri.parse('$kDeployedUrl/api/users/${user.userId}');
    final response = await http.put(url,
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user.');
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

  static Future<void> saveGoogleSignIn(bool isGoogleSignIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('google_sign_in', isGoogleSignIn);
  }

  static Future<bool?> getGoogleSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('google_sign_in');
  }
}
