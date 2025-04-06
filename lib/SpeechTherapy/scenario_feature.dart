import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScenarioScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scenarios = [
    {
      'title': 'Restaurant',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/neuroapp-5d6c2.firebasestorage.app/o/InShot_20250326_015231031.mp4?alt=media&token=cc6de5d8-327a-4f4f-a72f-2d26c2fc1d6f',
      'image': 'assets/images/restaurant.png',
    },
    {
      'title': 'Doctor',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/neuroapp-5d6c2.firebasestorage.app/o/InShot_20250326_015641128.mp4?alt=media&token=2f5160d5-e2cf-46b5-990e-6691a46321ca',
      'image': 'assets/images/doctor.png',
    },
  ];

  ScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        title: Row(
          children: [
            Image.asset('assets/images/luna.png', height: 32),
            const SizedBox(width: 10),
            const Text(
              'Scenario Game',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 24,
                color: Color(0xFFF5F5DC),
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Color(0xFFFFBF00), blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black26),
              child: Text(
                'Luna Menu',
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  fontSize: 24,
                  color: Color(0xFFF5F5DC),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF5F5DC)),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Color(0xFFF5F5DC),
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children:
              scenarios.map((scenario) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => VideoScreen(
                              videoUrl: scenario['videoUrl'],
                              scenarioTitle: scenario['title'],
                            ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: screenSize.height * 0.45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFBF00),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFBF00).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(3, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(scenario['image'], fit: BoxFit.cover),
                          Container(
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              scenario['title'],
                              style: const TextStyle(
                                fontFamily: 'OpenDyslexic',
                                fontSize: 24,
                                color: Color(0xFFF5F5DC),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFFFBF00),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      //bottomNavigationBar: _buildDynamicBottomNavBar(context),
    );
  }

  // Widget _buildDynamicBottomNavBar(BuildContext context) {
  //   return BottomNavigationBar(
  //     backgroundColor: const Color(0xFF121212),
  //     selectedItemColor: const Color(0xFFFFBF00),
  //     unselectedItemColor: Colors.grey,
  //     type: BottomNavigationBarType.fixed,
  //     currentIndex: 0,
  //     onTap: (index) {
  //       switch (index) {
  //         case 0:
  //           Navigator.pushNamedAndRemoveUntil(
  //             context,
  //             '/home',
  //             (route) => false,
  //           );
  //           break;
  //         case 1:
  //           Navigator.pushNamed(context, '/forum');
  //           break;
  //         case 2:
  //           Navigator.pushNamed(context, '/search');
  //           break;
  //         case 3:
  //           Navigator.pushNamed(context, '/chatbot');
  //           break;
  //         case 4:
  //           Navigator.pushNamed(context, '/profile');
  //           break;
  //       }
  //     },
  //     elevation: 10,
  //     selectedLabelStyle: const TextStyle(fontFamily: 'AtkinsonHyperlegible'),
  //     items: [
  //       _buildNavItem(Icons.home, 'Home'),
  //       _buildNavItem(Icons.people_outline, 'Forum'),
  //       _buildNavItem(Icons.search, 'Search'),
  //       _buildNavItem(Icons.chat_bubble_outline, 'Chatbot'),
  //       _buildNavItem(Icons.person_outline, 'Profile'),
  //     ],
  //   );
  // }

  // BottomNavigationBarItem _buildNavItem(IconData iconData, String label) {
  //   return BottomNavigationBarItem(
  //     icon: Container(
  //       padding: const EdgeInsets.all(4),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: const Color(0xFFFFBF00), width: 1),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Icon(iconData),
  //     ),
  //     label: label,
  //   );
  // }
}

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String scenarioTitle;

  const VideoScreen({
    super.key,
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
  bool _isProcessing = false;
  bool _videoEnded = false;
  bool _isListening = false;

  String _compliment = "";
  String _overallReview = "";
  int _currentPrompt = 0;

  final List<String> _feedbacks = [];
  List<Map<String, dynamic>> _prompts = [];

  final Map<String, List<Map<String, dynamic>>> scenarioPrompts = {
    'Restaurant': [
      {
        "time": 17,
        "context":
            "The user is at a burger joint, speaking politely to place an order.",
      },
      {
        "time": 24,
        "context":
            "The cashier offers fries after taking the main order. The user should respond clearly.",
      },
      {
        "time": 33,
        "context":
            "The user is expected to say how they will pay, e.g. 'I will pay by card'.",
      },
    ],
    'Doctor': [
      {
        "time": 18,
        "context":
            "The user is at a doctor's office, explaining their symptoms.",
      },
      {
        "time": 23,
        "context":
            "The doctor asks for more details. The user should explain where it hurts and how it feels.",
      },
      {
        "time": 33,
        "context":
            "The doctor inquires about the duration and pattern of the pain.",
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _prompts = scenarioPrompts[widget.scenarioTitle] ?? [];

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startPauseListener();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          !_videoEnded) {
        _videoEnded = true;
        _generateOverallReview();
      }
    });
  }

  void _startPauseListener() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentPrompt >= _prompts.length || _videoEnded) {
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
      setState(() {
        _isListening = true;
      });
      _speech.listen(
        onResult: (val) async {
          if (val.finalResult) {
            _speech.stop();
            await _analyzeSpeech(val.recognizedWords);
            setState(() {
              _isListening = false;
            });
          }
        },
      );
    }
  }

  Future<void> _speakAndWait(String text) async {
    final completer = Completer();
    _tts.setCompletionHandler(() {
      completer.complete();
    });
    await _tts.speak(text);
    await completer.future;
  }

  Future<void> _analyzeSpeech(String userSpeech) async {
    final contextText = _prompts[_currentPrompt]['context'];
    String previousFeedback =
        _feedbacks.isNotEmpty ? _feedbacks.join("\n") : "";
    String prompt = '''
User said: "$userSpeech"
Context: "$contextText"
Previous Feedback:
$previousFeedback

Generate a one-liner upbeat response tailored to the user's speech style.
''';

    setState(() {
      _isProcessing = true;
      _showMic = false;
    });

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([Content.text(prompt)]);
      String complimentMessage =
          response.text ?? "Excellent work. Keep shining!";
      _feedbacks.add(complimentMessage);
      setState(() {
        _compliment = complimentMessage;
        _isProcessing = false;
      });
      await _speakAndWait(_compliment);
      await Future.delayed(const Duration(seconds: 2));
      _controller.play();
      setState(() {
        _isPaused = false;
        _currentPrompt++;
        _compliment = '';
      });
    } catch (e) {
      setState(() {
        _compliment = "";
        _isProcessing = false;
      });
    }
  }

  Future<void> _generateOverallReview() async {
    String prompt = 'Based on the feedback:\n';
    for (int i = 0; i < _feedbacks.length; i++) {
      prompt += 'Feedback ${i + 1}: "${_feedbacks[i]}"\n';
    }
    prompt += 'Provide an overall review in 2-4 sentences.';

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([Content.text(prompt)]);
      String review =
          response.text ??
          "Overall, focus on clearer articulation and consistent pacing.";
      setState(() {
        _overallReview = review;
      });
      await _speakAndWait(_overallReview);
    } catch (e) {
      setState(() {
        _overallReview =
            "Error generating overall review. Please try again later.";
      });
      await _speakAndWait(_overallReview);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;
    final tapButtonBottomPadding = mediaHeight * 0.05;

    if (_videoEnded && _overallReview.isNotEmpty) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: mediaWidth * 0.03,
                  top: mediaHeight * 0.02,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              if (_controller.value.isInitialized)
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              else
                SizedBox(
                  height: mediaHeight * 0.25,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(mediaWidth * 0.05),
                    margin: EdgeInsets.all(mediaWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _overallReview,
                      style: TextStyle(
                        fontSize: mediaWidth * 0.045,
                        color: Colors.black,
                        fontFamily: 'OpenDyslexic',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child:
                _controller.value.isInitialized
                    ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                    : const CircularProgressIndicator(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: mediaWidth * 0.03,
                top: mediaHeight * 0.02,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          if (_compliment.isNotEmpty)
            Center(
              child: Container(
                padding: EdgeInsets.all(mediaWidth * 0.04),
                margin: EdgeInsets.symmetric(horizontal: mediaWidth * 0.07),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _compliment,
                  style: TextStyle(
                    fontSize: mediaWidth * 0.045,
                    color: Colors.black,
                    fontFamily: 'OpenDyslexic',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (_isPaused && _showMic && !_isProcessing)
            Positioned(
              bottom: tapButtonBottomPadding,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: mediaWidth * 0.06,
                        vertical: mediaHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: TextStyle(fontSize: mediaWidth * 0.045),
                    ),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: Text(
                      _isListening ? "Listening..." : "Tap to Speak",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                    onPressed: _startListening,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
