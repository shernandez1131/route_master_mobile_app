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
}
