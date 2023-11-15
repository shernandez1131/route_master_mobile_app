import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as st;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PaymentScreen extends StatefulWidget {
  final double monto;

  PaymentScreen({Key? key, required this.monto}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;
  late st.CardEditController controller;
  st.CardFieldInputDetails? cardDetails;

  @override
  void initState() {
    super.initState();
    controller = st.CardEditController();
    controller.addListener(onCardChanged);
  }

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();
      var gpay = const st.PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "US", testEnv: true);
      await st.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: st.SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!["client_scret"],
        style: ThemeMode.light,
        merchantDisplayName: "RouteMaster",
        googlePay: gpay,
      ));
      displayPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await st.Stripe.instance.presentPaymentSheet();
      print("Done");
    } catch (e) {
      print("Failed");
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": widget.monto,
        "currency": "US",
      };
      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51OBC14Ew7UVJPn6si1ymYg76Pnin479ybVJaLCbzJ0qOT1zte6zTXXTWxlPXGx3DFbyH8G45za6PJhHVkOHbVMXi00umsm9NJP",
            "Content-Type": "application/x-www-form-urlendcoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void dispose() {
    controller.removeListener(onCardChanged);
    controller.dispose();
    super.dispose();
  }

  void onCardChanged() {
    setState(() {
      cardDetails = controller.details;
    });
  }

  Future<void> processPayment(BuildContext context) async {
    try {
      await st.Stripe.instance.confirmPayment(
          paymentIntentClientSecret: 'paymentIntentClientSecret');
    } on st.StripeError catch (e) {
      // Handle Stripe errors
      print('Error code: ${e.code}, Error message: ${e.message}');
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pagar S/. ${widget.monto} utilizando',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: st.CardField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Detalles de la tarjeta',
                  ),
                ),
              ),
              if (cardDetails?.complete ?? false)
                ElevatedButton(
                  onPressed: () async {
                    // Handle payment logic
                    await processPayment(context);
                  },
                  child: Text('Pagar S/. ${widget.monto}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
