import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Luna/SpeechTherapy/scenario_feature.dart';

class SpeechTherapyPage extends StatelessWidget {
  final User? user;

  const SpeechTherapyPage({super.key, this.user});

  // Replace these asset paths with your actual image paths.
  final List<String> imagePaths = const [
    'assets/images/PICTURE.png', // Picture Word - tapping this navigates to minimal pairs
    'assets/images/scenarios.png', // Tapping this navigates to Scenario screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B), // Greyish black background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2B2B),
        elevation: 4,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFFBF00), width: 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
            child: Image.asset('assets/images/luna.png', fit: BoxFit.contain),
          ),
        ),
        title: const Text(
          'Luna',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: Color(0xFFFFBF00), // Golden accent text
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
          ),
        ),
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
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFBF00), width: 1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 5,
                    color: Colors.black38,
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePaths[index], fit: BoxFit.cover),
                ),
              ),
            ),
          );
        },
      ),
      // bottomNavigationBar: AppBottomNavBar(
      //   user: user,
      //   onHomeTap: () {
      //     Navigator.pushNamed(context, '/home');
      //   },
      // ),
    );
  }
}

// class AppBottomNavBar extends StatelessWidget {
//   final User? user;
//   final VoidCallback onHomeTap;

//   const AppBottomNavBar({super.key, this.user, required this.onHomeTap});

  // Helper widget to wrap icons with a subtle golden border and shadow.
  // Widget _buildNavIcon(Widget icon) {
  //   return Container(
  //     padding: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: const Color(0xFFFFBF00), width: 1),
  //       borderRadius: BorderRadius.circular(8),
  //       boxShadow: const [
  //         BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26),
  //       ],
  //     ),
  //     child: icon,
  //   );
  // }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       backgroundColor: const Color(0xFF121212),
//       selectedItemColor: const Color(0xFFF5F5DC), // Creamy white
//       unselectedItemColor: Colors.grey,
//       type: BottomNavigationBarType.fixed,
//       currentIndex: 0, // Home is the default selected index.
//       onTap: (index) {
//         if (index == 0) {
//           onHomeTap();
//         } else if (index == 1) {
//           Navigator.pushNamed(context, '/scenario');
//         }
//       },
//       items: [
//         BottomNavigationBarItem(
//           icon: _buildNavIcon(const Icon(Icons.home)),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildNavIcon(const Icon(Icons.people)),
//           label: 'Forum',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildNavIcon(const Icon(Icons.search)),
//           label: 'Search',
//         ),
//         BottomNavigationBarItem(
//           icon: _buildNavIcon(const Icon(Icons.chat)),
//           label: 'Chatbot',
//         ),
//         BottomNavigationBarItem(
//           icon:
//               user?.photoURL != null
//                   ? _buildNavIcon(
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(user!.photoURL!),
//                       radius: 12,
//                     ),
//                   )
//                   : _buildNavIcon(const Icon(Icons.person)),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }
