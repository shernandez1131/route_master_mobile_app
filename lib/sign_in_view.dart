import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/map_view.dart';
import 'login_service.dart';
import 'register_view.dart';
import 'user_model.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final LoginService loginService = LoginService('https://10.0.2.2:7243');
  // Replace with your actual base URL

  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _signIn(User user) async {
    try {
      setState(() => isLoading = true);
      final response = await loginService.authenticate(user);
      final token = response['token']
          as String; // Assuming 'token' is the key for the bearer token in the response
      await loginService.saveToken(token);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapView()),
        );
      }
    } catch (e) {
      // Handle authentication error
      debugPrint('Authentication failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text;
                    final password = passwordController.text;
                    final user = User(
                      email: email,
                      password: password,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    await _signIn(user);
                  },
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 10),
                const Text('¿O si no está registrado?'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterView()),
                    );
                  },
                  child: const Text('Registrarse'),
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
}
