import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  final Color creamyWhite = const Color(0xFFF5F5DC);
  final Color golden = const Color(0xFFFFBF00);
  final Color darkGrey = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final double loginFontSize = MediaQuery.of(context).size.width * 0.08;

    return Scaffold(
      backgroundColor: darkGrey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and app name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Luna',
                      style: TextStyle(
                        fontFamily: 'AtkinsonHyperlegible',
                        color: golden,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: golden, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/luna.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Login title
                Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    fontSize: loginFontSize,
                    fontWeight: FontWeight.bold,
                    color: creamyWhite,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black87,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Email field
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                  obscureText: false,
                ),

                const SizedBox(height: 20),

                // Password field
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),

                const SizedBox(height: 16),

                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),

                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: golden,
                      foregroundColor: darkGrey,
                      elevation: 10,
                      shadowColor: golden.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: creamyWhite,
                        fontFamily: 'AtkinsonHyperlegible',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: golden,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AtkinsonHyperlegible',
                          shadows: const [
                            Shadow(
                              blurRadius: 1,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: golden, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: creamyWhite, fontFamily: 'OpenDyslexic'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: golden, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/verification');
          }
        } else {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getFriendlyErrorMessage(e.code);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      default:
        return 'Login failed. Please check your details.';
    }
  }
}
