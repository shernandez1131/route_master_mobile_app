import 'package:flutter/material.dart';
import '../services/login_service.dart';
import 'map_screen.dart';
import '../models/passenger_model.dart';

class CompleteRegisterView extends StatefulWidget {
  final int userId;

  const CompleteRegisterView({Key? key, required this.userId})
      : super(key: key);

  @override
  State<CompleteRegisterView> createState() => _CompleteRegisterViewState();
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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Register')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'Nombres')),
                TextField(
                    controller: lastNameController,
                    decoration:
                        const InputDecoration(labelText: 'Apellido Paterno')),
                TextField(
                    controller: lastName2Controller,
                    decoration:
                        const InputDecoration(labelText: 'Apellido Materno')),
                TextField(
                    controller: phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Número de teléfono')),
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
                  decoration:
                      const InputDecoration(labelText: 'Método de Pago'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final passenger = Passenger(
                      userId: widget.userId,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      lastName2: lastName2Controller.text,
                      phoneNumber: phoneNumberController.text,
                      isActive: true,
                      paymentMethodId: int.parse(paymentMethodController.text),
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    await _completeRegister(passenger);
                  },
                  child: const Text('Completar Registro'),
                ),
              ],
            ),
          ),

          // Loading overlay
          isLoading
              ? Container(
                  color: Colors.black
                      .withOpacity(0.5), // Semi-transparent background
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(), // An empty SizedBox when not loading
        ],
      ),
    );
  }

  Future<void> _completeRegister(Passenger passenger) async {
    try {
      setState(() => isLoading = true);
      await loginService.completeRegister(passenger);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
    } catch (e) {
      // Handle error
      debugPrint('Complete registration failed: $e');
    } finally {
      setState(() => isLoading = false);
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
