import 'package:flutter/material.dart';
import 'login_service.dart';
import 'map_view.dart';
import 'passenger_model.dart';

class CompleteRegisterView extends StatefulWidget {
  final int userId;

  const CompleteRegisterView({Key? key, required this.userId})
      : super(key: key);

  @override
  _CompleteRegisterViewState createState() => _CompleteRegisterViewState();
}

class _CompleteRegisterViewState extends State<CompleteRegisterView> {
  final LoginService loginService = LoginService(
      'https://10.0.2.2:7243'); // Replace with your actual base URL
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController lastName2Controller = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();

  List<Map<String, dynamic>> paymentMethods = [
    {'id': 1, 'name': 'Tarjeta de Crédito'},
    {'id': 2, 'name': 'Tarjeta de Débito'},
    {'id': 3, 'name': 'Yape/Plin'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'Nombres')),
            TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Apellido Paterno')),
            TextField(
                controller: lastName2Controller,
                decoration: InputDecoration(labelText: 'Apellido Materno')),
            TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Número de teléfono')),
            DropdownButtonFormField<int>(
              value: paymentMethodController.text.isNotEmpty
                  ? int.parse(paymentMethodController.text)
                  : null,
              items: paymentMethods.map((method) {
                return DropdownMenuItem<int>(
                  value: method['id'],
                  child: Text(method['name']),
                );
              }).toList(),
              onChanged: (value) {
                paymentMethodController.text = value.toString();
              },
              decoration: InputDecoration(labelText: 'Método de Pago'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final passenger = Passenger(
                  userId: widget.userId,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  lastName2: lastName2Controller.text,
                  phoneNumber: phoneNumberController.text,
                  isActive: true,
                  paymentMethodId: int.parse(paymentMethodController.text),
                );

                _completeRegister(passenger);
              },
              child: Text('Completar Registro'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeRegister(Passenger passenger) async {
    try {
      await loginService.completeRegister(passenger);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapView()),
      );
    } catch (e) {
      // Handle error
      print('Complete registration failed: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    lastName2Controller.dispose();
    phoneNumberController.dispose();
    paymentMethodController.dispose();
    super.dispose();
  }
}
