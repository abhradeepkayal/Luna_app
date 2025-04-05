import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neuro_app/Activites/activites_main.dart';
import 'package:neuro_app/Journal/journal_main.dart';

import 'package:neuro_app/MainChatbot/chatbot.dart';
import 'package:neuro_app/SpeechTherapy/scenario_feature.dart';
import 'Start/login_screen.dart';
import 'Start/home_screen.dart';
import 'Start/verification_pending_screen.dart';
import 'SpeechTherapy/speech_therapy.dart';
import 'SpeechTherapy/picture_to_word.dart';
import 'firebase_options.dart';
// import '../Journal/journal_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found or failed to load.");
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuro App',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF5F5DC),
          onPrimary: Colors.black,
          surface: Color(0xFF1E1E1E),
          onSurface: Color(0xFFF5F5DC),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'OpenDyslexic',
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/verification': (context) => const VerificationPendingScreen(),
        '/speech-therapy':
            (context) =>
                SpeechTherapyPage(user: FirebaseAuth.instance.currentUser),
        '/pictureToWord': (context) => const PictureToWord(),
        '/scenario': (context) => ScenarioScreen(),
        '/chatbot': (context) => ChatbotScreen(),
        '/journal': (context) => const JournalMain(),
        '/activities': (context) => const ActivitesMain(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;
          if (user != null && user.emailVerified) {
            return const HomeScreen();
          } else {
            return const VerificationPendingScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
