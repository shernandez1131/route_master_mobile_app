import 'package:flutter/material.dart';

class TransferBalanceWaitingScreen extends StatefulWidget {
  const TransferBalanceWaitingScreen({super.key});

  @override
  State<TransferBalanceWaitingScreen> createState() =>
      _TransferBalanceWaitingScreenState();
}

class _TransferBalanceWaitingScreenState
    extends State<TransferBalanceWaitingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibir Saldo'),
      ),
      body: const Center(
        child: Text('Recibir Saldo'),
      ),
    );
  }
}
