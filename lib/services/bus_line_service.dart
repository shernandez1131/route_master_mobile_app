import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

import '../models/models.dart';
import 'package:http/http.dart' as http;

class BusLineService {
  static List<BusLine> parseBusLines(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<BusLine>((json) => BusLine.fromJson(json)).toList();
  }

  static Future<List<BusLine>> getBusLines() async {
    final url = Uri.parse('$kDeployedUrl/api/buslines');
    final token = await UserService.getToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return compute(parseBusLines, response.body);
    } else {
      throw Exception('Failed to load bus lines');
    }
  }
}
