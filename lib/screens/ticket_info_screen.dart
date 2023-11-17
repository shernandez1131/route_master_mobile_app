import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/models/ticket_model.dart';

class TicketInfoScreen extends StatelessWidget {
  final Ticket ticket;
  final bool isFromQrScan;
  final Function(dynamic) callback;

  const TicketInfoScreen(
      {super.key,
      required this.ticket,
      required this.isFromQrScan,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'images/ticket_background.png',
            fit: BoxFit.fill,
          ),
          // Company Name
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Text(
              ticket.companyName,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Bus Name
          Positioned(
            top: 270,
            left: 0,
            right: 0,
            child: Text(
              ticket.busName,
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
          ),
          // Fares
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ticket.fares.entries
                  .map((e) => Text(
                        '${e.key}: s/${e.value}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Aceptar Button and Ticket Number
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Ticket Number
                Text(
                  '#${ticket.number.toString().padLeft(7, '0')}',
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                // Aceptar Button
                ElevatedButton(
                  onPressed: () {
                    if (isFromQrScan) {
                      callback(ticket);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
