import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:route_master_mobile_app/constants.dart';

import '../models/models.dart';

class TicketService {
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
