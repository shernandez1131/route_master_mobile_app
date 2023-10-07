import 'package:flutter/material.dart';
import 'complete_register.dart';
import '../services/services.dart';
import 'sign_in_screen.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                      isActive: true,
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                      (route) => false,
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
      user = await UserService.register(user);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteRegisterView(
              user: user,
              password: passwordController.text,
            ),
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
