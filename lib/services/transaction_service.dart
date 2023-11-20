import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

import '../models/models.dart';

class TransactionService {
  static List<Transaction> parseTransactions(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed
        .map<Transaction>((json) => Transaction.fromJson(json))
        .toList();
  }

  static Future<List<Transaction>> getTransactionsByWalletId(
      int walletId) async {
    final url = Uri.parse('$kDeployedUrl/api/transactions/wallet/$walletId');
    final token = await UserService.getToken();

    final response = await http.get(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return compute(parseTransactions, response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  // generate static funtion to create a transaction
  static Future<Transaction> createRechargeTransaction(
      Transaction transaction) async {
    final url = Uri.parse('$kDeployedUrl/api/rechargetransactions');
    final token = await UserService.getToken();

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create recharge transaction');
    }
  }

  static Future<Transaction> createPaymentTransaction(
      Transaction transaction) async {
    final url = Uri.parse('$kDeployedUrl/api/paymenttransactions');
    final token = await UserService.getToken();

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create payment transaction');
    }
  }

  static Future<Transaction> createTransferTransaction(
      Transaction transaction) async {
    final url = Uri.parse('$kDeployedUrl/api/transfertransactions');
    final token = await UserService.getToken();

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(transaction.toJsonTransfer()),
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transaction');
    }
  }
}
