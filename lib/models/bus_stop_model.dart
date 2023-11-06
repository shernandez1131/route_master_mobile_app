class BusStop {
  final int busStopId;
  final String name;
  final double latitude;
  final double longitude;
  final int vehicleTypeId;

  BusStop({
    required this.busStopId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.vehicleTypeId,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      busStopId: json['stopId'], // Update key name
      name: json['name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      vehicleTypeId: json['vehicleTypeId'],
    );
  }
}
