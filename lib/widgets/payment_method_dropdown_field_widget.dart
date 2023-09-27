import 'package:flutter/material.dart';

import '../models/models.dart';

class PaymentMethodDropdownField extends StatefulWidget {
  final int selectedPaymentMethodId;
  final bool isReadOnly;
  const PaymentMethodDropdownField(
      {super.key,
      required this.selectedPaymentMethodId,
      required this.isReadOnly});

  @override
  State<PaymentMethodDropdownField> createState() =>
      _PaymentMethodDropdownFieldState();
}

class _PaymentMethodDropdownFieldState
    extends State<PaymentMethodDropdownField> {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(paymentMethodId: 1, name: 'Tarjeta de crédito'),
    PaymentMethod(paymentMethodId: 2, name: 'Tarjeta de débito'),
    PaymentMethod(paymentMethodId: 3, name: 'Yape / Plin'),
  ];

  late PaymentMethod selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    setPaymentMethod();
  }

  void setPaymentMethod() {
    selectedPaymentMethod = paymentMethods
        .where((element) =>
            element.paymentMethodId == widget.selectedPaymentMethodId)
        .first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Método de pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 65.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButton<PaymentMethod>(
              value: selectedPaymentMethod,
              items: paymentMethods.map((PaymentMethod paymentMethod) {
                return DropdownMenuItem<PaymentMethod>(
                  value: paymentMethod,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(paymentMethod.name),
                  ),
                );
              }).toList(),
              onChanged: !widget.isReadOnly
                  ? (PaymentMethod? newValue) {
                      setState(() {
                        selectedPaymentMethod =
                            newValue ?? selectedPaymentMethod;
                      });
                    }
                  : null,
              isExpanded: true,
              underline: Container(),
              itemHeight: 65.0,
            ),
          ),
        ],
      ),
    );
  }
}
