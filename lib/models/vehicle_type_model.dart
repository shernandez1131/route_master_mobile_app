class VehicleType {
  final int vehicleTypeId;
  final String name;

  VehicleType({
    required this.vehicleTypeId,
    required this.name,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      vehicleTypeId: json['vehicleTypeId'],
      name: json['name'],
    );
  }
}
