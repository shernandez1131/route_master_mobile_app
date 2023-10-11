class Ticket {
  final String companyName;
  final String busName;
  final int number;
  final Map<String, String> fares; // For various fare types and their prices
  double? amount; // Nullable, as it might not be available initially

  Ticket({
    required this.companyName,
    required this.busName,
    required this.fares,
    required this.number,
    this.amount,
  });

  // Constructor to create a Ticket instance from a Map
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      companyName: json['companyName'],
      busName: json['busName'],
      fares: Map<String, String>.from(json['fares']),
      number: 0,
      // amount is not from QR code, will be added later
    );
  }
}
