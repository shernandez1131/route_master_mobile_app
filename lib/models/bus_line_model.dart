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
  final String oldCode;
  final String? logo;

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
    required this.oldCode,
    this.logo,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      lineId: json['lineId'],
      code: json['code'],
      firstStop: json['firstStop'],
      lastStop: json['lastStop'],
      alias: json['alias'],
      color: json['color'],
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
      companyId: json['companyId'],
      vehicleType: json['vehicleType'] != null
          ? VehicleType.fromJson(json['vehicleType'])
          : null,
      vehicleTypeId: json['vehicleTypeId'],
      oldCode: json['oldCode'],
      logo: json['logo'],
    );
  }
}
