import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Luna/SpeechTherapy/scenario_feature.dart';

class SpeechTherapyPage extends StatelessWidget {
  final User? user;

  const SpeechTherapyPage({super.key, this.user});

  
  final List<String> imagePaths = const [
    'assets/images/PICTURE.png', 
    'assets/images/scenarios.png', 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B), 
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
            color: Color(0xFFFFBF00), 
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
                
                Navigator.pushNamed(context, '/pictureToWord');
              } else if (index == 1) {
                
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
      
    );
  }
}

