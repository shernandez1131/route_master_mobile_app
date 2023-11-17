import 'dart:convert';

import 'package:route_master_mobile_app/models/models.dart';

class Trip {
  final int? tripId;
  final int userId;
  final DateTime startDate;
  late DateTime endDate;
  late double totalPrice;
  final List<TripDetail>? tripDetails;

  Trip({
    this.tripId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.tripDetails,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    List<TripDetail> tripDetails = [];
    if (json['busTripDetails'] != null) {
      List<dynamic> tripDetailsJson = json['busTripDetails'] as List;

      for (var trip in tripDetailsJson) {
        var tripString = jsonEncode(trip);
        var castedJson = jsonDecode(tripString) as Map<String, dynamic>;
        var tripDetail = TripDetail.fromJson(castedJson);
        tripDetails.add(tripDetail);
      }
    }
    return Trip(
      tripId: json['tripId'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalPrice: json['totalPrice'],
      tripDetails: tripDetails,
    );
  }
}
