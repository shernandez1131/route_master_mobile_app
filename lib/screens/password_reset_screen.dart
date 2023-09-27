import 'package:flutter/material.dart';

import '../services/services.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController emailController = TextEditingController();

  void _requestReset(BuildContext context) async {
    final String email = emailController.text;

    // Check if the email is registered in the database
    //final bool isEmailRegistered = await User.checkEmailInDatabase(email);

    if (isEmailRegistered) {
      // Generate and send a verification code to the user's email
      final String verificationCode = generateVerificationCode();

      // Send the verification code to the user's email address (e.g., via email or SMS)

      // Navigate to the verification code input screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordResetVerificationScreen(
            email: email,
            verificationCode: verificationCode,
          ),
        ),
      );
    } else {
      // Email is not registered; show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email address not registered.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestReset(context),
              child: Text('Request Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
