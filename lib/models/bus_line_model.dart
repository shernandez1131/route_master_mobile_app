import 'models.dart';

class BusLine {
  final int busLineId;
  final String code;
  final String firstStop;
  final String lastStop;
  final String? alias;
  final String color;
  final Company? company;
  final int companyId;
  final LineType? lineType;
  final int lineTypeId;

  BusLine({
    required this.busLineId,
    required this.code,
    required this.firstStop,
    required this.lastStop,
    this.alias,
    required this.color,
    this.company,
    required this.companyId,
    this.lineType,
    required this.lineTypeId,
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      busLineId: json['busLineId'],
      code: json['code'],
      firstStop: json['firstStop'],
      lastStop: json['lastStop'],
      alias: json['alias'],
      color: json['color'],
      company: Company.fromJson(json['company']),
      companyId: json['companyId'],
      lineType: LineType.fromJson(json['lineType']),
      lineTypeId: json['lineTypeId'],
    );
  }
}
