class Ticket {
  final String companyName;
  final String busName;
  final int number;
  late Map<String, String> fares; // For various fare types and their prices
  double? amount; // Nullable, as it might not be available initially
  late int userId;

  Ticket({
    required this.companyName,
    required this.busName,
    required this.fares,
    required this.number,
    required this.userId,
    this.amount,
  });

  // Constructor to create a Ticket instance from a Map
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      companyName: json['companyName'],
      busName: json['busName'],
      fares:
          json['fares'] != null ? Map<String, String>.from(json['fares']) : {},
      number: json['number'] ?? 0,
      userId: json['userId'] ?? 0,
      // amount is not from QR code, will be added later
    );
  }
}
