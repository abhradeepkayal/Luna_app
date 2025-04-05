import 'dart:io';
    import 'package:flutter/material.dart';
    import 'package:image_picker/image_picker.dart';
    import 'package:firebase_auth/firebase_auth.dart';

    class SignUpPage extends StatefulWidget {
      const SignUpPage({super.key});

      @override
      State<SignUpPage> createState() => _SignUpPageState();
    }

    class _SignUpPageState extends State<SignUpPage> {
      // Controllers for text fields
      final TextEditingController _nicknameController = TextEditingController();
      final TextEditingController _emailController = TextEditingController();
      final TextEditingController _passwordController = TextEditingController();

      // Optional profile image file from gallery
      File? _profileImageFile;
      final ImagePicker _picker = ImagePicker();

      // Pick an image from the gallery
      Future<void> _pickImageFromGallery() async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _profileImageFile = File(pickedFile.path);
          });
        }
      }

      // ✅ Create account logic with verification
      Future<void> _createAccount() async {
        final nickname = _nicknameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill out all required fields.')),
            );
          }
          return;
        }

        try {
          // Firebase Auth sign-up
          final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Send email verification
          await credential.user?.sendEmailVerification();

          // Optionally update displayName, etc.
          if (credential.user != null) {
            await credential.user!.updateDisplayName(nickname);
            // If you want to upload _profileImageFile to Firebase Storage,
            // do that here and update user photoURL if needed.
          }

          // ✅ Navigate to verification screen
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/verification');
          }
        } on FirebaseAuthException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signup Error: ${e.message}')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        // Calculate a scalable font size for the "Signup" text based on screen width.
        final double signupFontSize = MediaQuery.of(context).size.width * 0.08;

        return Scaffold(
          // No AppBar — layout is replicated in the body
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Row with the app name and logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Luna',
                          style: TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    color: Color.fromARGB(255, 254, 203, 18),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                        ),
                        const SizedBox(width: 8),
                        // Logo
                        Image.asset(
                          'assets/images/luna.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    
                    // Spacing before "Signup" text
                    const SizedBox(height: 20),
                    
                    // "Signup" text styled in Atkinson Hyperlegible, bold and responsive
                    Text(
                      'Signup',
                      style: TextStyle(
                        fontFamily: 'AtkinsonHyperlegible',
                        fontSize: signupFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Additional spacing similar to the login page
                    const SizedBox(height: 40),
                    
                    // Profile image (optional)
                    InkWell(
                      onTap: _pickImageFromGallery,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : null,
                        child: _profileImageFile == null
                            ? const Icon(Icons.add_a_photo, size: 30, color: Colors.black54)
                            : null,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Nickname TextField
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email TextField
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password TextField
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    
                    // Create Account Button
                    ElevatedButton(
                      onPressed: _createAccount,
                      child: const Text('Create Account'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // "Already have an account?" normal + "Login" clickable
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Equal spacing at the bottom is automatically handled by SafeArea.
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }