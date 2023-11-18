import 'package:route_master_mobile_app/models/models.dart';

class TripDetail {
  late int tripDetailId;
  late int tripId;
  final int? vehicleId;
  final int lineId;
  late int originStopId;
  late int destinationStopId;
  final int order;
  final double price;
  final int vehicleTypeId;
  final String startCoordinates;
  final String finalCoordinates;
  final BusLine? busLine;
  final Rating? rating;

  TripDetail({
    required this.tripId,
    required this.tripDetailId,
    this.vehicleId,
    required this.lineId,
    required this.originStopId,
    required this.destinationStopId,
    required this.order,
    required this.price,
    required this.vehicleTypeId,
    required this.startCoordinates,
    required this.finalCoordinates,
    this.busLine,
    this.rating,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) {
    return TripDetail(
      tripId: json['tripId'],
      tripDetailId: json['tripDetailId'],
      vehicleId: json['vehicleId'],
      vehicleTypeId: json['vehicleTypeId'],
      lineId: json['lineId'],
      originStopId: json['originStopId'],
      destinationStopId: json['destinationStopId'],
      order: json['order'],
      price: json['price'],
      startCoordinates: '',
      finalCoordinates: '',
      busLine:
          json['busLine'] != null ? BusLine.fromJson(json['busLine']) : null,
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }
}
