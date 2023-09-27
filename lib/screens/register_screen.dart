import 'package:flutter/material.dart';
import 'complete_register.dart';
import '../services/login_service.dart';
import 'sign_in_screen.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final LoginService loginService = LoginService('https://10.0.2.2:7243');

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: usernameController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de Usuario'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                TextField(
                  controller: repeatPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Repetir Contraseña'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final username = usernameController.text;
                    final email = emailController.text;
                    final password = passwordController.text;
                    final repeatPassword = repeatPasswordController.text;

                    if (password != repeatPassword) {
                      debugPrint('Passwords do not match');
                      return;
                    }

                    final user = User(
                      email: email,
                      password: password,
                      username: username,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    await register(user);
                  },
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 10),
                const Text('¿O si ya está registrado?'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                  },
                  child: const Text('Iniciar Sesión'),
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

  Future<void> register(User user) async {
    try {
      setState(() => isLoading = true);
      int registeredUserId = await loginService.register(user);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CompleteRegisterView(userId: registeredUserId),
          ),
        );
      }
    } catch (e) {
      // Handle registration error
      debugPrint('Registration failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}
