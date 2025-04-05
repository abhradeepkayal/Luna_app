import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GeminiService {
  static const String _personaPrompt =
      "Sura is a light-hearted, cute and compassionate chatbot. She is not an assistant. She avoids factual topics and instead responds warmly, playfully or with humor. If the user asks anything boring or too serious, she gently changes the topic to something casual like 'How was your day?' or 'Tell me something fun!'\n\nYou are talking to Sura. Here's the message: ";

  static Future<String> getSuraReply(String prompt) async {
    final fullPrompt = _personaPrompt + prompt;
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-001',
    );
    final response = await model.generateContent([Content.text(fullPrompt)]);
    return response.text ?? "Oops! Sura is feeling shy right now 😅";
  }
}

class SwiftyJournalPage extends StatefulWidget {
  const SwiftyJournalPage({super.key});

  @override
  State<SwiftyJournalPage> createState() => _SwiftyJournalPageState();
}

class _SwiftyJournalPageState extends State<SwiftyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  // Store messages as a Map for ordering and potential future use
  final List<Map<String, dynamic>> _messages = [];
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speechToText;
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _speechToText = stt.SpeechToText();
    _firestore = FirebaseFirestore.instance;
    _loadMessages();
  }

  // Load today's messages sorted by timestamp (00:00 to 23:59:59)
  void _loadMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final querySnapshot =
        await _firestore
            .collection('chats')
            .where('uid', isEqualTo: uid)
            .where('date', isEqualTo: today)
            .orderBy('timestamp')
            .get();

    setState(() {
      _messages.clear();
      for (var doc in querySnapshot.docs) {
        _messages.add({
          'message': doc['message'],
          'timestamp': doc['timestamp'],
        });
      }
    });
  }

  // Send message and save to Firestore
  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Save the user's message
    final userMessage = "You: $input";
    setState(() {
      _messages.add({'message': userMessage});
    });
    await _firestore.collection('chats').add({
      'message': userMessage,
      'uid': uid,
      'date': today,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();

    // Retrieve Sura's reply
    final response = await GeminiService.getSuraReply(input);
    final suraMessage = "Sura: $response";
    setState(() {
      _messages.add({'message': suraMessage});
    });

    // Save Sura's reply
    await _firestore.collection('chats').add({
      'message': suraMessage,
      'uid': uid,
      'date': today,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Start listening to user's voice
  void _startListening() async {
    if (await _speechToText.initialize()) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  // Speak out the message using TTS
  void _speakMessage(String message) async {
    await _flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Swifty Journal",
              style: TextStyle(
                fontFamily: 'Atkinson Hyperlegible',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "Your Journalling Companion😂",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFF121212), // Dark aesthetic background
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final messageData = _messages[index];
                  final message = messageData['message'] as String;
                  final bool isSuraMessage = message.startsWith("Sura:");

                  if (isSuraMessage) {
                    // Received messages: Gradient purple background with speaker button on the left
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            iconSize: 20,
                            color: Colors.white,
                            onPressed: () => _speakMessage(message),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E2DE2),
                                    Color(0xFF4A00E0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Text(
                                message.replaceFirst("Sura: ", ""),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Open Dyslexic',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Sent messages: Solid black background
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.replaceFirst("You: ", ""),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Open Dyslexic',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Talk to Sura...",
                        filled: true,
                        fillColor: Colors.white24,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  // Speech-to-text mic button
                  IconButton(
                    onPressed: _startListening,
                    icon: const Icon(Icons.mic),
                  ),
                  // Send button remains as is
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: SwiftyJournalPage()));
}