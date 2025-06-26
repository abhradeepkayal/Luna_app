import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      appBar: AppBar(
        title: Text(
          "FORUM",
          style: const TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5EBDC),
            shadows: [
              Shadow(
                blurRadius: 3,
                color: Colors.black54,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Join Groups and Communities",
              style: const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF5EBDC),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(seconds: 1),
              child: Text(
                "Coming Soon...",
                style: const TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5EBDC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
