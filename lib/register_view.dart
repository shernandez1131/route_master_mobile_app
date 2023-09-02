import 'package:flutter/material.dart';
import 'login_service.dart';
import 'sign_in_view.dart';
import 'user_model.dart';

class RegisterView extends StatelessWidget {
  final LoginService loginService = LoginService(
      'https://10.0.2.2:7243'); // Replace with your actual base URL

  Future<void> _register(User user) async {
    try {
      await loginService.register(user);

      // Successfully registered, you can navigate to the sign-in page or perform other actions
    } catch (e) {
      // Handle registration error
      print('Registration failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController repeatPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            TextField(
              controller: repeatPasswordController,
              decoration: InputDecoration(labelText: 'Repetir Contraseña'),
            ),
            ElevatedButton(
              onPressed: () {
                final username = usernameController.text;
                final email = emailController.text;
                final password = passwordController.text;
                final repeatPassword = repeatPasswordController.text;

                if (password != repeatPassword) {
                  print('Passwords do not match');
                  return;
                }

                final user = User(
                  email: email,
                  password: password,
                  username: username,
                );
                _register(user);
              },
              child: Text('Registrarse'),
            ),
            // SizedBox(height: 10),
            // Text('¿O si ya está registrado?'),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => SignInView()),
            //     );
            //   },
            //   child: Text('Iniciar Sesión'),
            // ),
          ],
        ),
      ),
    );
  }
}
