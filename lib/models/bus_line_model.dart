import 'models.dart';

class BusLine {
  final int lineId;
  final String code;
  final String firstStop;
  final String lastStop;
  final String? alias;
  final String color;
  final Company? company;
  final int companyId;
  final VehicleType? vehicleType;
  final int vehicleTypeId;

  BusLine({
    required this.lineId,
    required this.code,
    required this.firstStop,
    required this.lastStop,
    this.alias,
    required this.color,
    this.company,
    required this.companyId,
    this.vehicleType,
    required this.vehicleTypeId,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      lineId: json['lineId'],
      code: json['code'],
      firstStop: json['firstStop'],
      lastStop: json['lastStop'],
      alias: json['alias'],
      color: json['color'],
      company: Company.fromJson(json['company']),
      companyId: json['companyId'],
      vehicleType: VehicleType.fromJson(json['vehicleType']),
      vehicleTypeId: json['vehicleTypeId'],
    );
  }
}
