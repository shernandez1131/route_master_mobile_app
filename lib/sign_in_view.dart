import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/map_view.dart';
import 'login_service.dart';
import 'register_view.dart';
import 'user_model.dart';

class SignInView extends StatelessWidget {
  final LoginService loginService = LoginService(
      'https://10.0.2.2:7243'); // Replace with your actual base URL

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future<void> _signIn(User user) async {
      try {
        final response = await loginService.authenticate(user);
        final token = response['token']
            as String; // Assuming 'token' is the key for the bearer token in the response
        await loginService.saveToken(token);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapView()),
        );
      } catch (e) {
        // Handle authentication error
        print('Authentication failed: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;

                final user = User(
                  email: email,
                  password: password,
                );
                _signIn(user);
              },
              child: Text('Iniciar Sesión'),
            ),
            SizedBox(height: 10),
            Text('¿O si no está registrado?'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterView()),
                );
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
