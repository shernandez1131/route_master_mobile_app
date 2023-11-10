import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

import '../models/models.dart';
import 'package:http/http.dart' as http;

class BusStopService {
  static List<BusStop> parseBusStops(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<BusStop>((json) => BusStop.fromJson(json)).toList();
  }

  static Future<List<BusStop>> getBusStops() async {
    final url = Uri.parse('$kDeployedUrl/api/BusStops');
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
      return compute(parseBusStops, response.body);
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  static Future<List<BusStop>> getBusStopsByUserId(busLineId) async {
    final url = Uri.parse('$kDeployedUrl/api/BusStops/$busLineId/busline');
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
      return compute(parseBusStops, response.body);
    } else {
      throw Exception('Failed to load bus stops');
    }
  }
}
