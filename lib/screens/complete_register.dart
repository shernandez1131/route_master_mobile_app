import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/services/wallet_service.dart';
import '../models/models.dart';
import '../services/login_service.dart';
import 'map_screen.dart';

class CompleteRegisterView extends StatefulWidget {
  final User user;
  final String password;

  const CompleteRegisterView(
      {Key? key, required this.user, required this.password})
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
                      userId: widget.user.userId,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      lastName2: lastName2Controller.text,
                      phoneNumber: phoneNumberController.text,
                      isActive: true,
                      paymentMethodId: int.parse(paymentMethodController.text),
                    );
                    final wallet = Wallet(
                      walletId: 0,
                      userId: widget.user.userId,
                      balance: 0,
                      lastUpdate: DateTime.now(),
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      isLoading = true;
                    });
                    await _completeRegister(passenger, wallet);
                    setState(() {
                      isLoading = false;
                    });
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

  Future<void> _completeRegister(Passenger passenger, Wallet wallet) async {
    final String token;
    final int userId;

    try {
      final User userAuth = User(
          userId: widget.user.userId,
          email: widget.user.email,
          password: widget.password);
      final response = await loginService.authenticate(userAuth);
      token = response['token']
          as String; // Assuming 'token' is the key for the bearer token in the response
      userId = response['userId'] as int;
      await LoginService.saveToken(token);
      await LoginService.saveUserId(userId).then((value) => null);
      await loginService.completeRegister(passenger);
      await WalletService.postWallet(wallet, token);
    } catch (e) {
      // Handle authentication error
      debugPrint('Authentication failed: $e');
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
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
