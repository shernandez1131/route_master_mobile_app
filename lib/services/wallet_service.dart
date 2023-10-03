import 'dart:convert';
import 'dart:io';

import '../constants.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;

class WalletService {
  static Future<Wallet> postWallet(Wallet wallet, String token) async {
    final url = Uri.parse('$kEmulatorLocalhost/api/wallets');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'userId': wallet.userId,
          'balance': wallet.balance,
          'lastUpdate': wallet.lastUpdate.toIso8601String(),
        },
      ),
    );

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create wallet');
    }
  }

  static Future<Wallet> putWallet(Wallet wallet, String token) async {
    final url = Uri.parse('$kEmulatorLocalhost/api/wallets/${wallet.walletId}');

    final response = await http.put(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'userId': wallet.userId,
          'balance': wallet.balance,
          'lastUpdate': wallet.lastUpdate.toIso8601String(),
        },
      ),
    );

    if (response.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update wallet');
    }
  }
}
