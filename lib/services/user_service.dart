import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';

import '../models/models.dart';

class UserService {
  static Future<User?> checkEmail(String email, String token) async {
    final url = Uri.parse('$kEmulatorLocalhost/api/users/get-by-email');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
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

  static Future<User> updateUser(User user, String? token) {
    final url = Uri.parse('$kEmulatorLocalhost/api/users/${user.userId}');
    return http
        .put(url,
            headers: <String, String>{
              HttpHeaders.acceptHeader: 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: 'Bearer $token',
            },
            body: jsonEncode(user.toJson()))
        .then((response) {
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user.');
      }
    });
  }
}
