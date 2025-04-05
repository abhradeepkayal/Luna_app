import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_vertexai/firebase_vertexai.dart';

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
    }
  ];

  ScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive image sizing.
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/images/luna.png', height: 32),
            const SizedBox(width: 10),
            const Text('Speech Therapy',
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Image with responsive width and padding.
                    Expanded(
                      child: Image.asset(
                        scenario['image'],
                        fit: BoxFit.cover,
                        width: screenSize.width * 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scenario['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'OpenDyslexic',
                      ),
                    ),
                  ],
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

  // Store the AI feedback for each prompt.
  final List<String> _feedbacks = [];
  
  List<Map<String, dynamic>> _prompts = [];

  final Map<String, List<Map<String, dynamic>>> scenarioPrompts = {
    'Restaurant': [
      {
        "time": 17,
        "context":
            "The user is at a burger joint, speaking to a friendly cashier. They are expected to place an order politely, like 'I’d like a cheeseburger, please.' Analyze tone, pronunciation, and word choice."
      },
      {
        "time": 24,
        "context":
            "The cashier offers fries after taking the main order. The user should respond clearly, either accepting or declining."
      },
      {
        "time": 33,
        "context":
            "The user is expected to say how they will pay. A complete sentence like 'I will pay by card' or 'Cash, please' is ideal."
      },
    ],
    'Doctor': [
      {
        "time": 18,
        "context":
            "The user is visiting a doctor. They should explain what they are feeling, using a complete sentence like 'I have been feeling unwell for a few days.'"
      },
      {
        "time": 23,
        "context":
            "The doctor asks for more details. The user is expected to say where it hurts and how it feels."
      },
      {
        "time": 33,
        "context":
            "The doctor asks how long the issue has lasted and if the pain moves. The user should give a clear timeline and additional symptoms if possible."
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    // Force landscape mode initially for video playback.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    // Set an alternative voice if available.
    _tts.getVoices.then((voices) {
      if (voices != null && voices.isNotEmpty) {
        // Choose the second voice if available; otherwise, use the first.
        var selectedVoice = voices.length > 1 ? voices[1] : voices[0];
        _tts.setVoice(selectedVoice);
      }
    });

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
      _speech.listen(onResult: (val) async {
        if (val.finalResult) {
          _speech.stop();
          await _analyzeSpeech(val.recognizedWords);
          setState(() {
            _isListening = false;
          });
        }
      });
    }
  }

  // Helper function that speaks and waits for completion.
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
    // Build the prompt using all previous feedback.
    String previousFeedback = _feedbacks.isNotEmpty ? _feedbacks.join("\n") : "";
    String prompt = '''
User said: "$userSpeech"
Context: "$contextText"
Previous Feedback:
$previousFeedback

Generate a EXACTLY one-liner upbeat response tailored to the user's speech style:
-If they sound nervous or hesitant or give a slighlt wrong answer with respect to the context, offer playful encouragement.
-If they speak smoothly and confidently, match their energy with enthusiastic praise.
-If they crack a joke or get sarcastic, respond with a witty, fun comeback.
-If they say something inappropriate, only then rebuke them and tell hem that it is not acceptable. Tell them to use this
feature seriously. (Give two short sentences response in this case).
Keep it light, friendly, and hype them up—like a fun coach, never robotic or formal. One-liners only!
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
      
      // Save this feedback for use in future prompts.
      _feedbacks.add(complimentMessage);

      setState(() {
        _compliment = complimentMessage;
        _isProcessing = false;
      });

      // Wait for TTS to finish, then wait 2 extra seconds.
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

  // Generate the overall review using the accumulated feedback.
  Future<void> _generateOverallReview() async {
    String prompt = 'Based on the following feedback responses from your speaking performance:\n';
    for (int i = 0; i < _feedbacks.length; i++) {
      prompt += 'Feedback ${i + 1}: "${_feedbacks[i]}"\n';
    }
    prompt += '''
Please provide an overall review in EXACTLY 2-4 sentences that is guiding, fun, and helpful.
Highlight the user's strengths and offer constructive suggestions for improvement—focusing on tone,
clarity, stuttering, pronunciation, pacing, context, and/or situational awareness.
Base your review on real-world usage and avoid any academic or bookish commentary.
''';

    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );

      final response = await model.generateContent([Content.text(prompt)]);
      String review = response.text ??
          "Overall, focus on clearer articulation and consistent pacing.";
      setState(() {
        _overallReview = review;
      });
      await _speakAndWait(_overallReview);
      // After speaking the final review, leave it on screen.
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
    // Restore orientation settings when leaving this screen.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve dynamic sizes using MediaQuery.
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;
    final tapButtonBottomPadding = mediaHeight * 0.05; // 5% of screen height

    // If the video ended, switch to portrait mode and show final overview in a 
    // vertical layout with the video at the top (paused) and the AI remark below.
    if (_videoEnded && _overallReview.isNotEmpty) {
      // Force portrait mode now that the video is finished.
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Back button at top left using relative padding.
              Padding(
                padding: EdgeInsets.only(left: mediaWidth * 0.03, top: mediaHeight * 0.02),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Show the final paused frame at the top.
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
              
              // The AI remark in a scrollable area.
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

    // Otherwise, show the video in landscape mode with our usual overlays.
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
          // Back button at top left using SafeArea.
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: mediaWidth * 0.03, top: mediaHeight * 0.02),
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
          // AI feedback overlay.
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
          // "Tap to Speak" floating-style button placed at the center bottom.
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
                        // Using withAlpha to convert 0.2 opacity to alpha value.
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        offset: const Offset(0, 4),
                        blurRadius: 6,
                      )
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