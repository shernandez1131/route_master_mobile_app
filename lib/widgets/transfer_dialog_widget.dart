import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/screens.dart';

class TransferDialog extends StatefulWidget {
  final String passengerBalance;
  const TransferDialog({super.key, required this.passengerBalance});
  @override
  _TransferDialogState createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  late TextEditingController _transferAmountController;
  late Color _buttonColor = Colors.grey; // Default button color

  @override
  void initState() {
    super.initState();
    _transferAmountController = TextEditingController();
    _transferAmountController.addListener(_updateButtonColor);
  }

  @override
  void dispose() {
    _transferAmountController.removeListener(_updateButtonColor);
    _transferAmountController.dispose();
    super.dispose();
  }

  void _updateButtonColor() {
    String amountText = _transferAmountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _buttonColor =
            Colors.grey; // Set button color to grey if the field is empty
      });
      return;
    }

    double? transferAmount = double.tryParse(amountText);
    setState(() {
      if (transferAmount != null &&
          transferAmount <= double.parse(widget.passengerBalance)) {
        _buttonColor = Colors
            .green; // Set button color to green if parsing succeeds and is less than or equal to the balance
      } else {
        _buttonColor = Colors
            .grey; // Set button color to grey if parsing fails or exceeds the balance
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transferir saldo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('¿Cuál monto desea transferir de su monedero?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('S/. ', style: TextStyle(fontSize: 20)),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _transferAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Monto',
                  ),
                  onChanged: (_) {
                    setState(() {}); // Update the dialog when text changes
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // Add logic to handle the recharge action
            String amountText = _transferAmountController.text.trim();
            if (amountText.isNotEmpty) {
              double transferAmount = double.parse(amountText);
              if (transferAmount <= double.parse(widget.passengerBalance)) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransferBalanceScreen(
                    saldo: transferAmount.toString(),
                  ),
                ));
              }
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              return _buttonColor; // Use the color set dynamically based on conditions
            }),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: const Text('Recargar'),
        ),
      ],
    );
  }
}
