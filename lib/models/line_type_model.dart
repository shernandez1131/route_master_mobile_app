class LineType {
  final int lineTypeId;
  final String name;

  LineType({
    required this.lineTypeId,
    required this.name,
  });

  factory LineType.fromJson(Map<String, dynamic> json) {
    return LineType(
      lineTypeId: json['lineTypeId'],
      name: json['name'],
    );
  }
}
