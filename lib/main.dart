import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Luna/Activites/activites_main.dart';
import 'package:Luna/Journal/journal_main.dart';
import 'package:Luna/MainChatbot/chatbot.dart';
import 'package:Luna/SpeechTherapy/scenario_feature.dart';
import 'package:Luna/aboutus.dart';
import 'package:Luna/contact.dart';
import 'package:Luna/forum.dart';
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
import 'package:Luna/profile.dart';
import 'package:Luna/search.dart';
import 'package:video_player/video_player.dart'; // Added for splash video

// import '../Journal/journal_main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ); // Make sure you have this icon in your project.

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
      title: 'Luna',
      debugShowCheckedModeBanner: false,
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
      home: const SplashScreenWrapper(), // Modified to add splash video
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
        '/aboutUs': (context) => const AboutUsPage(),
        '/contact': (context) => const ContactPage(),
        '/profile': (context) => const ProfilePage(),
        '/search': (context) => const SearchPage(),
        '/forum': (context) => const ForumPage(),
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

// --- Added Splash Video Functionality Below ---
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  late VideoPlayerController _controller;
  bool _videoFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/splash_video.mp4")
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the initialized video
        _controller.play();
      });
    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration &&
          !_videoFinished) {
        _videoFinished = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(color: Colors.black),
    );
  }
}
