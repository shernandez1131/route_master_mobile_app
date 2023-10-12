class BusStop {
  final int busStopId;
  final String name;
  final double latitude;
  final double longitude;

  BusStop({
    required this.busStopId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      busStopId: json['busStopId'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
