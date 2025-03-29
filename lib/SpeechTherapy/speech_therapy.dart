import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuro_app/SpeechTherapy/scenario_feature.dart';

class SpeechTherapyPage extends StatelessWidget {
  final User? user;

  const SpeechTherapyPage({super.key, this.user});

  // Replace these asset paths with your actual image paths.
  final List<String> imagePaths = const [
    'assets/images/codeforces.png', // Picture Word - tapping this navigates to minimal pairs
    'assets/images/garfield.png',   // Tapping this navigates to Scenario screen
    'assets/images/mindora.png',    // (No action)
    'assets/images/ruskinbond.png', // (No action)
    'assets/images/NeuroApp.jpeg',  // (No action)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Logo on the left side of the AppBar.
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/NeuroApp.jpeg',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('NeuroApp'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                // Navigate to PictureToWord page (minimal pairs)
                Navigator.pushNamed(context, '/pictureToWord');
              } else if (index == 1) {
                // Navigate to Scenario screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScenarioScreen()),
                );
              }
              // For other images, no action is taken.
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        user: user,
        onHomeTap: () {
          Navigator.pushNamed(context, '/home');
        },
      ),
    );
  }
}

class AppBottomNavBar extends StatelessWidget {
  final User? user;
  final VoidCallback onHomeTap;

  const AppBottomNavBar({super.key, this.user, required this.onHomeTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF121212),
      selectedItemColor: const Color(0xFFF5F5DC),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Home is the default selected index.
      onTap: (index) {
        if (index == 0) {
          onHomeTap();
        } else if (index == 1) {
          Navigator.pushNamed(context, '/scenario');
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Forum'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        BottomNavigationBarItem(
          icon: user?.photoURL != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user!.photoURL!),
                  radius: 12,
                )
              : const Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
