import 'package:flutter/material.dart';

class TransferBalanceScreen extends StatefulWidget {
  final String saldo;
  const TransferBalanceScreen({super.key, required this.saldo});

  @override
  State<TransferBalanceScreen> createState() => _TransferBalanceScreenState();
}

class _TransferBalanceScreenState extends State<TransferBalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencia de Saldo'),
      ),
      body: Center(
        child: Text('Transferencia de S/. ${widget.saldo}'),
      ),
    );
  }
}
