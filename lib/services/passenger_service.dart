import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';

import '../models/models.dart';

class PassengerService {
  static Future<Passenger?> getPassengerByUserId(
      int userId, String token) async {
    final url = Uri.parse(
        '$kEmulatorLocalhost/api/passengers/$userId'); // Replace with your actual API endpoint URL

    final response = await http.get(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Passenger.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load passenger data');
    }
  }

  static Future<Passenger?> createPassenger(Passenger passenger) async {
    final url = Uri.parse('$kEmulatorLocalhost/api/passengers');
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
      'Content-Type': 'application/json; charset=UTF-8'
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(passenger.toJson()),
    );

    if (response.statusCode == 200) {
      return Passenger.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed');
    }
  }

  static Future<Passenger?> updatePassenger(
      int userId, Passenger passenger, String token) async {
    final url = Uri.parse('$kEmulatorLocalhost/api/passengers/$userId');

    final response = await http.put(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(passenger.toJson()),
    );

    if (response.statusCode == 200) {
      return Passenger.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update passenger data');
    }
  }
}
