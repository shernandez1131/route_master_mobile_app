class TransactionType {
  int transactionTypeId;
  String name;

  TransactionType({
    required this.transactionTypeId,
    required this.name,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
      transactionTypeId: json['transactionTypeId'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionTypeId': transactionTypeId,
      'name': name,
    };
  }
}
