import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class ScenarioScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scenarios = [
    {
      'title': 'Restaurant',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/neuroapp-5d6c2.firebasestorage.app/o/InShot_20250326_015231031.mp4?alt=media&token=cc6de5d8-327a-4f4f-a72f-2d26c2fc1d6f',
    },
    {
      'title': 'Doctor',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/neuroapp-5d6c2.appspot.com/o/InShot_20250326_015641128.mp4?alt=media', // Replace with real doctor video URL
    }
  ];

  ScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/images/NeuroApp.jpeg', height: 32),
            const SizedBox(width: 10),
            const Text('NeuroNarratives',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: scenarios.map((scenario) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoScreen(
                    videoUrl: scenario['videoUrl'],
                    scenarioTitle: scenario['title'],
                  ),
                ),
              );
            },
            child: Card(
              color: const Color(0xFF1E1E1E),
              child: Center(
                child: Text(
                  scenario['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'OpenDyslexic',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  BottomNavigationBar _bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF121212),
      selectedItemColor: const Color(0xFFF5F5DC),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Forum'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String scenarioTitle;

  const VideoScreen({super.key, 
    required this.videoUrl,
    required this.scenarioTitle,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  late stt.SpeechToText _speech;
  late FlutterTts _tts;

  bool _isPaused = false;
  bool _showMic = false;
  String _compliment = "";
  int _currentPrompt = 0;

  List<Map<String, dynamic>> _prompts = [];

  final Map<String, List<Map<String, dynamic>>> scenarioPrompts = {
    'Restaurant': [
      {
        "time": 17,
        "context":
            "The user is at a burger joint, speaking to a friendly cashier. They’re expected to place an order politely, like 'I’d like a cheeseburger, please.' Analyze tone, pronunciation, and word choice. Compliment them on being clear and polite."
      },
      {
        "time": 24,
        "context":
            "The cashier offers fries after taking the main order. The user should respond clearly, either accepting or declining. Look for clarity, confidence, and if the answer fits the context (like 'Yes, please' or 'No, thank you')."
      },
      {
        "time": 33,
        "context":
            "The user is expected to say how they’ll pay. A complete sentence like 'I’ll pay by card' or 'Cash, please' is ideal. Assess pronunciation and response fit."
      },
    ],
    'Doctor': [
      {
        "time": 18,
        "context":
            "The user is visiting a doctor. They should explain what they're feeling, using a complete sentence like 'I've been feeling unwell for a few days.' Evaluate clarity, tone, and how well they express their symptoms."
      },
      {
        "time": 23,
        "context":
            "The doctor asks for more details. The user is expected to say where it hurts and how it feels. Look for good use of descriptive words and speaking confidence."
      },
      {
        "time": 33,
        "context":
            "The doctor asks how long the issue has lasted and if the pain moves. The user should give a clear timeline and additional symptoms if possible. Check clarity, relevance, and fluency."
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _prompts = scenarioPrompts[widget.scenarioTitle] ?? [];

    if (_prompts.isEmpty) {
      print("⚠️ No prompts available for scenario: ${widget.scenarioTitle}");
    }

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startPauseListener();
      });
  }

  void _startPauseListener() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentPrompt >= _prompts.length) {
        timer.cancel();
        return;
      }

      final pauseTime = _prompts[_currentPrompt]['time'];
      if (_controller.value.position.inSeconds >= pauseTime &&
          !_isPaused &&
          _controller.value.isPlaying) {
        _pauseAndShowMic();
      }
    });
  }

  void _pauseAndShowMic() {
    _controller.pause();
    setState(() {
      _isPaused = true;
      _showMic = true;
    });
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      print("🎤 Speech listening...");
      _speech.listen(onResult: (val) async {
        print("🔊 Heard: ${val.recognizedWords}, isFinal: ${val.finalResult}");
        if (val.finalResult) {
          _speech.stop();
          await _analyzeSpeech(val.recognizedWords);
        }
      });
    } else {
      print("❌ Speech recognition not available.");
    }
  }

  Future<void> _analyzeSpeech(String userSpeech) async {
    final contextText = _prompts[_currentPrompt]['context'];
    print("🧠 Sending to AI — Context: $contextText | User said: $userSpeech");

    try {
      final response = await http.post(
        Uri.parse('https://us-central1-neuroapp-5d6c2.cloudfunctions.net/analyzeSpeech'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "context": contextText,
          "user_input": userSpeech
        }),
      );

      print("📡 Response status: ${response.statusCode}");
      print("📡 Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _compliment = response.body;
          _showMic = false;
        });
        await _tts.speak(_compliment);
        await Future.delayed(const Duration(seconds: 2));
        _controller.play();
        setState(() {
          _isPaused = false;
          _currentPrompt++;
          _compliment = '';
        });
      } else {
        setState(() {
          _compliment = "Couldn't analyze your input.";
        });
      }
    } catch (e) {
      print("❌ AI error: $e");
      setState(() {
        _compliment = "Something went wrong. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),

          if (_isPaused)
            Container(
              color: Colors.black.withOpacity(0.6),
            ),

          if (_isPaused && _currentPrompt < _prompts.length)
            Positioned(
              bottom: 160,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _prompts[_currentPrompt]['context'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'OpenDyslexic',
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (_compliment.isNotEmpty)
            Center(
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    border: Border.all(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _compliment,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.greenAccent,
                      fontFamily: 'OpenDyslexic',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          if (_isPaused && _showMic)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Tap to speak',
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _startListening,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Icon(Icons.mic, size: 40, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
