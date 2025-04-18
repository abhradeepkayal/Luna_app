import 'package:flutter/material.dart';
import 'jumbledwords.dart'; 
import 'puzzles.dart'; 
class ActivitesMain extends StatelessWidget {
  const ActivitesMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neurodiverse App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'OpenDyslexic', color: Colors.white),
          bodyMedium: TextStyle(
            fontFamily: 'OpenDyslexic',
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neurodiverse Features"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const JumbledWordsApp(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Image.asset('assets/images/Jumble.png', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const PuzzlesPage(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Image.asset(
                'assets/images/Puzzle_f.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
