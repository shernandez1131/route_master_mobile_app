import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/models/ticket_model.dart';

class TicketInfoScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketInfoScreen({super.key, required this.ticket});

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
          // Back Button
          Positioned(
            top: 60,
            left: 35,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Company Name
          Positioned(
            top: 150,
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
            top: 210,
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
                    Navigator.pop(context);
                    Navigator.pop(context);
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
