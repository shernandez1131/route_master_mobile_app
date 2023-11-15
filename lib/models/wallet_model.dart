class Wallet {
  int walletId;
  int userId;
  String balance;
  DateTime lastUpdate;

  Wallet({
    required this.walletId,
    required this.userId,
    required this.balance,
    required this.lastUpdate,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['walletId'] as int,
      userId: json['userId'] as int,
      balance: json['balance'],
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'userId': userId,
      'balance': balance,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}
