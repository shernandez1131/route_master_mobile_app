import 'models.dart';

class Transaction {
  final int? transactionId;
  final int? transactionTypeId;
  final TransactionType? transactionType;
  final int walletId;
  final Wallet? wallet;
  final double amount;
  final DateTime date;
  final String status;
  final String description;
  final int? recipientWalletId;
  final Wallet? recipientWallet;

  Transaction({
    this.transactionId,
    this.transactionTypeId,
    this.transactionType,
    required this.walletId,
    this.wallet,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
    this.recipientWalletId,
    this.recipientWallet,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      transactionTypeId: json['transactionTypeId'],
      transactionType: json['transactionType'] != null
          ? TransactionType.fromJson(json['transactionType'])
          : null,
      walletId: json['walletId'],
      wallet: json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null,
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      description: json['description'],
      recipientWalletId: json['recipientWalletId'],
      recipientWallet: json['recipientWallet'] != null
          ? Wallet.fromJson(json['recipientWallet'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description
    };
  }

  Map<String, dynamic> toJsonTransfer() {
    return {
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
      'recipientWalletId': recipientWalletId,
    };
  }
}
