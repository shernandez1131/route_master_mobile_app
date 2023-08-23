import 'package:flutter/material.dart';
import 'sign_in_view.dart';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Nombre')),
            TextField(decoration: InputDecoration(labelText: 'Correo')),
            TextField(decoration: InputDecoration(labelText: 'Contraseña')),
            TextField(
                decoration: InputDecoration(labelText: 'Repetir Contraseña')),
            ElevatedButton(onPressed: () {}, child: Text('Registrarse')),
            SizedBox(height: 10),
            Text('¿O si ya está registrado?'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInView()),
                );
              },
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
