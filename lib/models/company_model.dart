class Company {
  final int companyId;
  final String name;
  final String ruc;

  Company({
    required this.companyId,
    required this.name,
    required this.ruc,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'],
      name: json['name'],
      ruc: json['ruc'],
    );
  }
}
