class Company {
  final int companyId;
  final String name;

  Company({
    required this.companyId,
    required this.name,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'],
      name: json['name'],
    );
  }
}
