import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:route_master_mobile_app/screens/home_screen.dart';
import 'package:route_master_mobile_app/services/user_service.dart';
import '../models/user_model.dart';
import 'screens.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _signIn(User user) async {
    try {
      setState(() => isLoading = true);
      final response = await UserService.authenticate(user);
      if (response == null) {
        throw Exception('Authentication failed');
      }
      final token = response.token;
      final userId = response.userId;
      await UserService.saveToken(token!);
      await UserService.saveUserId(userId!);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
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
  late User? existingUser;
  late User? googleUser;

  Future<void> _handleSignIn() async {
    setState(() => isLoading = true);
    try {
      _currentUser = await _googleSignIn.signIn();

      // This line fixes the crash
      if (_currentUser == null) throw Exception("Not logged in");

      if (_currentUser != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await _currentUser!.authentication;
        late User user;
        try {
          existingUser = await UserService.checkEmail(_currentUser!.email);
          if (existingUser != null) {
            if (existingUser!.googleId != null) {
              await _signIn(existingUser!);
              await UserService.saveGoogleSignIn(true);
              return;
            }
            user = User(
              userId: existingUser!.userId,
              username: existingUser!.username,
              email: existingUser!.email,
              password: null,
              token: googleSignInAuthentication.idToken,
              isActive: true,
              googleId: _currentUser!.id,
            );
            googleUser = await UserService.updateUser(user);
            if (googleUser != null) {
              await _signIn(googleUser!);
              await UserService.saveGoogleSignIn(true);
            }
            return;
          }
          user = User(
            email: _currentUser!.email,
            token: googleSignInAuthentication.idToken,
            isActive: true,
            googleId: _currentUser!.id,
          );
          user = await UserService.register(user);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CompleteRegisterView(
                        user: user,
                        googleUser: _currentUser,
                      )),
            );
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    //check if shared preferences has token and userid
    setState(() {
      isLoading = true;
    });
    UserService.getToken().then((token) {
      if (token != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
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
                    await UserService.saveGoogleSignIn(false);
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
                  onPressed: () async => await _handleSignIn(),
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
