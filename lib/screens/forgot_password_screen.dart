import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'screens.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  late User? user;
  bool isLoading = false;
  bool isCodeSent = false;

  void _requestReset(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isLoading = true;
    });
    final String email = emailController.text;
    final String? token = await LoginService.getToken();

    user = await UserService.checkEmail(email, token ?? '');

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este correo no está registrado.'),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
      isCodeSent = true;
    });
  }

  void _validateCode(BuildContext context) {
    if (user != null) {
      if (user!.token == codeController.text) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(user: user!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El código ingresado es incorrecto.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé mi contraseña'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  enabled: !isCodeSent,
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 20),
                !isCodeSent
                    ? ElevatedButton(
                        onPressed: () async => _requestReset(context),
                        child: const Text('Enviar código'),
                      )
                    : const SizedBox.shrink(),
                isCodeSent
                    ? TextField(
                        controller: codeController,
                        decoration:
                            const InputDecoration(labelText: 'Ingresa el código'),
                      )
                    : const SizedBox.shrink(),
                isCodeSent
                    ? ElevatedButton(
                        onPressed: () => _validateCode(context),
                        child: const Text('Validar código'),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          isLoading
              ? Container(
                  color: Colors.black
                      .withOpacity(0.5), // Semi-transparent background
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
