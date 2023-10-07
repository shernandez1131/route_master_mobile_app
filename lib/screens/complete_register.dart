import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'map_screen.dart';

class CompleteRegisterView extends StatefulWidget {
  final User user;
  final String? password;
  final GoogleSignInAccount? googleUser;

  const CompleteRegisterView(
      {Key? key, required this.user, this.password, this.googleUser})
      : super(key: key);

  @override
  State<CompleteRegisterView> createState() => _CompleteRegisterViewState();
}

class _CompleteRegisterViewState extends State<CompleteRegisterView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();

  List<Map<String, dynamic>> paymentMethods = [
    {'id': 1, 'name': 'Tarjeta de Crédito'},
    {'id': 2, 'name': 'Tarjeta de Débito'},
    {'id': 3, 'name': 'Yape/Plin'},
  ];

  bool isLoading = false;

  //override initstate to set text controllers

  @override
  void initState() {
    super.initState();
    if (widget.googleUser != null) {
      final List<String> names = widget.googleUser!.displayName!.split(' ');
      firstNameController.text = names[0];
      lastNameController.text = names[1];
      paymentMethodController.text = '3';
    }
  }

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
                    decoration: const InputDecoration(labelText: 'Nombre(s)')),
                TextField(
                    controller: lastNameController,
                    decoration:
                        const InputDecoration(labelText: 'Apellido(s)')),
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
                      userId: widget.user.userId!,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phoneNumber: phoneNumberController.text,
                      isActive: true,
                      paymentMethodId: int.parse(paymentMethodController.text),
                    );
                    final wallet = Wallet(
                      walletId: 0,
                      userId: widget.user.userId!,
                      balance: 0,
                      lastUpdate: DateTime.now(),
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      isLoading = true;
                    });
                    await _completeRegister(passenger, wallet);
                    await _createWallet(wallet);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                      );
                    }
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
    final String? token;
    final int? userId;

    try {
      final User userAuth = User(
          userId: widget.user.userId,
          email: widget.user.email,
          password: widget.password);
      final response = await UserService.authenticate(userAuth);
      if (response == null) {
        throw Exception('Authentication failed.');
      }
      token = response.token;
      userId = response.userId;
      await UserService.saveToken(token!);
      await UserService.saveUserId(userId!);

      await PassengerService.createPassenger(passenger);
    } catch (e) {
      // Handle authentication error
      debugPrint('Authentication failed: $e');
    }
  }

  Future<void> _createWallet(Wallet wallet) async {
    final String? token;
    token = await UserService.getToken();
    try {
      await WalletService.postWallet(wallet, token!);
    } catch (e) {
      // Handle authentication error
      debugPrint('Wallet creation failed: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    paymentMethodController.dispose();
    super.dispose();
  }
}
