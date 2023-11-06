import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

import '../models/models.dart';

class TripService {
  static List<Trip> parseTrips(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Trip>((json) => Trip.fromJson(json)).toList();
  }

  static Future<List<Trip>> getTripsByUser(int userId) async {
    final url = Uri.parse('$kDeployedUrl/api/trips/$userId/users');
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
      return compute(parseTrips, response.body);
    } else {
      throw Exception('Failed to load trips');
    }
  }

  static Future<TripDetail> postTripDetail(
      TripDetail tripDetail, String token) async {
    final url = Uri.parse('$kDeployedUrl/api/busTripDetails');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'tripId': tripDetail.tripId,
          'vehicleId': tripDetail.vehicleId,
          'vehicleTypeId': tripDetail.vehicleTypeId,
          'lineId': tripDetail.lineId,
          'originStopId': tripDetail.originStopId,
          'destinationStopId': tripDetail.destinationStopId,
          'order': tripDetail.order,
          'price': tripDetail.price
        },
      ),
    );

    if (response.statusCode == 200) {
      return TripDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create tripDetail');
    }
  }

  static Future<Trip> postTrip(Trip trip, String token) async {
    final url = Uri.parse('$kDeployedUrl/api/trips');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'userId': trip.userId,
          'startDate': trip.startDate.toIso8601String(),
          'endDate': trip.endDate.toIso8601String(),
          'totalPrice': trip.totalPrice
        },
      ),
    );

    if (response.statusCode == 200) {
      return Trip.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create trip');
    }
  }
}
