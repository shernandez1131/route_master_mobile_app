import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:route_master_mobile_app/services/user_service.dart';
import '../services/login_service.dart';
import '../models/user_model.dart';
import 'screens.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
      final userId = response['userId'] as int;
      await LoginService.saveToken(token);
      await LoginService.saveUserId(userId);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
    } catch (e) {
      // Handle authentication error
      debugPrint('Authentication failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'openid',
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
    clientId:
        '190291182211-m9art6d3h4ai44q1l079c8496f7d861s.apps.googleusercontent.com',
  );

  late GoogleSignInAccount? _currentUser;

  Future<void> _handleSignIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await _currentUser!.authentication;
        final user = User(
          userId: 0,
          username: _currentUser!.id,
          email: _currentUser!.email,
          password: "google",
          token: googleSignInAuthentication.idToken,
          isActive: true,
        );
        try {
          await UserService.checkEmail(user.email, user.token ?? '');
          await loginService.register(user);
        } catch (e) {
          debugPrint(e.toString());
        }
        await _signIn(user);
      }
    } catch (error) {
      print(error);
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
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()));
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text;
                    final password = passwordController.text;
                    final user = User(
                      userId: 0,
                      email: email,
                      password: password,
                    );
                    FocusManager.instance.primaryFocus?.unfocus();
                    await _signIn(user);
                  },
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 10),
                const Center(child: Text('O si no está registrado')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _handleSignIn,
                  child: const Text('Iniciar sesión con Google'),
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
