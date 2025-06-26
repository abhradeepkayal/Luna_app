import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF121212);
    const textColor = Color(0xFFFAF3E0);
    const accentGold = Color(0xFFFFD700);

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "No Name";
    final email = user?.email ?? "No Email";
    final photoURL = user?.photoURL;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Profile',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: accentGold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/bg_overlay.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentGold.withOpacity(0.6),
                          blurRadius: 25,
                          spreadRadius: 4,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: accentGold, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.black,
                      backgroundImage:
                          photoURL != null
                              ? NetworkImage(photoURL)
                              : const AssetImage(
                                    'assets/images/default_profile.png',
                                  )
                                  as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                 
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentGold.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'About',
                              style: TextStyle(
                                fontFamily: 'AtkinsonHyperlegible',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'This is your profile page. Here you can view your account information and achievements. '
                              'No changes can be made here.',
                              style: TextStyle(
                                fontFamily: 'OpenDyslexic',
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Rewards and Badges',
                      style: const TextStyle(
                        fontFamily: 'AtkinsonHyperlegible',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Coming soon...',
                      style: const TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
