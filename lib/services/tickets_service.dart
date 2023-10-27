import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';
import 'package:route_master_mobile_app/services/user_service.dart';

import '../models/models.dart';

class TicketService {
  static List<Ticket> parseTickets(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Ticket>((json) => Ticket.fromJson(json)).toList();
  }

  static Future<List<Ticket>> getTicketsByUser(int userId) async {
    final url =
        Uri.parse('$kDeployedUrl/api/tickets/getticketsbyuseridasync/$userId');
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
      return compute(parseTickets, response.body);
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  static Future<Ticket> postTicket(Ticket ticket, String token) async {
    final url = Uri.parse('$kDeployedUrl/api/tickets');

    final response = await http.post(
      url,
      headers: <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{
          'userId': ticket.userId,
          'companyName': ticket.companyName,
          'busName': ticket.busName,
        },
      ),
    );

    if (response.statusCode == 200) {
      return Ticket.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create ticket');
    }
  }
}
