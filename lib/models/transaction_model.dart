import 'models.dart';

abstract class Transaction {
  final int transactionId;
  final int transactionTypeId;
  final TransactionType transactionType;
  final int walletId;
  final Wallet wallet;
  final double amount;
  final DateTime date;
  final String status;
  final String description;

  Transaction({
    required this.transactionId,
    required this.transactionTypeId,
    required this.transactionType,
    required this.walletId,
    required this.wallet,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
  });
}

class PaymentTransaction extends Transaction {
  PaymentTransaction(
      {required super.transactionId,
      required super.transactionTypeId,
      required super.transactionType,
      required super.walletId,
      required super.wallet,
      required super.amount,
      required super.date,
      required super.status,
      required super.description});

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      transactionId: json['transactionId'] as int,
      transactionTypeId: json['transactionTypeId'] as int,
      transactionType: TransactionType.fromJson(json['transactionType']),
      walletId: json['walletId'] as int,
      wallet: Wallet.fromJson(json['wallet']),
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionTypeId': transactionTypeId,
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}

class RechargeTransaction extends Transaction {
  RechargeTransaction(
      {required super.transactionId,
      required super.transactionTypeId,
      required super.transactionType,
      required super.walletId,
      required super.wallet,
      required super.amount,
      required super.date,
      required super.status,
      required super.description});

  factory RechargeTransaction.fromJson(Map<String, dynamic> json) {
    return RechargeTransaction(
      transactionId: json['transactionId'] as int,
      transactionTypeId: json['transactionTypeId'] as int,
      transactionType: TransactionType.fromJson(json['transactionType']),
      walletId: json['walletId'] as int,
      wallet: Wallet.fromJson(json['wallet']),
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionTypeId': transactionTypeId,
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}

class TransferTransaction extends Transaction {
  final int recipientWalletId;
  final Wallet recipientWallet;

  TransferTransaction({
    required this.recipientWalletId,
    required this.recipientWallet,
    required super.transactionId,
    required super.transactionTypeId,
    required super.transactionType,
    required super.walletId,
    required super.wallet,
    required super.amount,
    required super.date,
    required super.status,
    required super.description,
  });

  factory TransferTransaction.fromJson(Map<String, dynamic> json) {
    return TransferTransaction(
      recipientWalletId: json['recipientWalletId'] as int,
      recipientWallet: Wallet.fromJson(json['recipientWallet']),
      transactionId: json['transactionId'] as int,
      transactionTypeId: json['transactionTypeId'] as int,
      transactionType: TransactionType.fromJson(json['transactionType']),
      walletId: json['walletId'] as int,
      wallet: Wallet.fromJson(json['wallet']),
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionTypeId': transactionTypeId,
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
      'recipientWalletId': recipientWalletId,
    };
  }
}
