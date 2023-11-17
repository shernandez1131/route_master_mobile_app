class Ticket {
  final int? ticketId;
  final String companyName;
  final String busName;
  final int number;
  final DateTime createdOn;
  late Map<String, String> fares; // For various fare types and their prices
  double? amount; // Nullable, as it might not be available initially
  late int userId;

  Ticket({
    this.ticketId,
    required this.companyName,
    required this.busName,
    required this.fares,
    required this.number,
    required this.userId,
    required this.createdOn,
    this.amount,
  });

  // Constructor to create a Ticket instance from a Map
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
        ticketId: json['ticketId'],
        companyName: json['companyName'],
        busName: json['busName'],
        fares: json['fares'] != null
            ? Map<String, String>.from(json['fares'])
            : {},
        number: json['number'] ?? 0,
        userId: json['userId'] ?? 0,
        createdOn: json['createdOn'] != null
            ? DateTime.parse(json['createdOn'])
            : DateTime(1970, 1, 1, 0, 0),
        amount: json['amount']);
  }
}
