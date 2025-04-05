import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neuro_app/Activites/activites_main.dart';
import 'package:neuro_app/Journal/journal_main.dart';
import 'package:neuro_app/MainChatbot/chatbot.dart';
import 'package:neuro_app/SpeechTherapy/scenario_feature.dart';
import 'package:neuro_app/aboutus.dart';
import 'package:neuro_app/contact.dart';
import 'Start/login_screen.dart';
import 'Start/home_screen.dart';
import 'Start/verification_pending_screen.dart';
import 'SpeechTherapy/speech_therapy.dart';
import 'SpeechTherapy/picture_to_word.dart';
import 'firebase_options.dart';
import 'visual/calming_music_home.dart';
import 'todo/todo_main_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// import '../Journal/journal_main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Make sure you have this icon in your project.

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // Load environment variables safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found or failed to load.");
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeNotifications();

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
        '/visual': (context) => CalmingMusicHome(),
        '/todo': (context) => const TodoMainPage(),
        '/aboutUs':(context) => const AboutUsPage(),
        '/contact':(context) => const ContactPage(),
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
