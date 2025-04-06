import 'package:flutter/material.dart';

class PuzzlesPage extends StatelessWidget {
  const PuzzlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      appBar: AppBar(
        title: Text(
          "Puzzles",
          style: const TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5EBDC), 
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: AnimatedOpacity(
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
      ),
    );
  }
}
