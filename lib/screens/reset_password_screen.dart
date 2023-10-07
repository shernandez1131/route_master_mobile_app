import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/models/user_model.dart';

import '../services/services.dart';

class ResetPasswordScreen extends StatefulWidget {
  final User user;
  const ResetPasswordScreen({super.key, required this.user});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: repeatPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Repeat Password',
                    hintText: 'Repeat your new password',
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // Handle save button press
                    String newPassword = newPasswordController.text;
                    String repeatPassword = repeatPasswordController.text;

                    if (newPassword == repeatPassword) {
                      setState(() {
                        isLoading = true;
                      });
                      final User updatedUser = User(
                          userId: widget.user.userId,
                          email: widget.user.email,
                          password: newPassword,
                          username: widget.user.username,
                          isActive: true);
                      await UserService.updateUser(updatedUser);
                      setState(() {
                        isLoading = false;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña actualizada.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        final nav = Navigator.of(context);
                        nav.pop();
                        nav.pop();
                      }
                    } else {
                      // Passwords do not match, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
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

  @override
  void dispose() {
    // Dispose of the controllers when the screen is disposed to prevent memory leaks.
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }
}
