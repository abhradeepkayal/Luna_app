import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _botType = 'Chill Guy';
  bool _isListening = false;
  bool _showBotList = false;
  bool _isImageLoading = false;
  String? _imagePath;

  final List<Map<String, String>> _bots = [
    {'name': 'Chill Guy', 'description': 'Cool, calm, funny, helpful'},
    {'name': 'Emma', 'description': 'Joyful, fun, sweet vibes'},
    {'name': 'Patrick', 'description': 'Wise, deep, smart, motivational'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }

  void _showWelcomeMessage() {
    final welcomeMessages = {
      'Chill Guy':
          "Hey there! I’m Chill Guy, cool, calm, and ready to help you. What’s up?",
      'Emma':
          "Hi! I’m Emma, your joyful and sweet assistant. How can I bring some fun today?",
      'Patrick':
          "Hello, I’m Patrick. I’m here to guide you with deep, insightful responses. Let’s dive into things!",
    };
    _addBotMessage(welcomeMessages[_botType]!);
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty && _imagePath == null) return;

    final userMessage = _controller.text;

    if (_imagePath != null) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: '[Image]',
            sender: 'user',
            imageFile: File(_imagePath!),
            onReadAloud: () => _readAloud("You sent an image."),
          ),
        );
      });
      await _saveMessageToFirestore('Image: $_imagePath', 'user');
      _imagePath = null;
    }

    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: userMessage,
            sender: 'user',
            onReadAloud: () => _readAloud(userMessage),
          ),
        );
        _controller.clear();
      });
      await _saveMessageToFirestore(userMessage, 'user');
      _getBotResponse(userMessage);
    }

    setState(() {});
  }

  Future<void> _getBotResponse(String message) async {
    String response = await GeminiAPI.getResponse(message, _botType);
    _addBotMessage(response);
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          sender: _botType,
          onReadAloud: () => _readAloud(text),
        ),
      );
    });
    _saveMessageToFirestore(text, 'bot');
  }

  Future<void> _saveMessageToFirestore(String text, String sender) async {
    await _firestore
        .collection('chats')
        .doc('chatbot_$_botType')
        .collection('messages')
        .add({
          'text': text,
          'sender': sender,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _loadMessages() async {
    final snapshot =
        await _firestore
            .collection('chats')
            .doc('chatbot_$_botType')
            .collection('messages')
            .orderBy('timestamp')
            .get();

    setState(() {
      _messages.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final sender = data['sender'];
        final text = data['text'];
        _messages.add(
          ChatMessage(
            text: text,
            sender: sender == 'bot' ? _botType : 'user',
            onReadAloud: () => _readAloud(text),
          ),
        );
      }
    });
  }

  void _startListening() async {
    if (await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _readAloud(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    setState(() => _isImageLoading = true);

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }

    setState(() => _isImageLoading = false);
  }

  void _switchBotType(String type) {
    setState(() {
      _botType = type;
      _messages.clear();
      _imagePath = null;
    });
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }

  void _toggleBotList() {
    setState(() => _showBotList = !_showBotList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _toggleBotList,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/avatars/$_botType.png'),
              ),
              const SizedBox(width: 8),
              Text(_botType),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_showBotList)
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children:
                    _bots.map((bot) {
                      return ListTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/avatars/${bot['name']}.png',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              bot['name']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          bot['description']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => _switchBotType(bot['name']!),
                      );
                    }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isImageLoading) const CircularProgressIndicator(),
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                children: [
                  Image.file(
                    File(_imagePath!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _imagePath = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() => _messages.clear()),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String sender;
  final VoidCallback onReadAloud;
  final File? imageFile;

  const ChatMessage({
    super.key,
    required this.text,
    required this.sender,
    required this.onReadAloud,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (sender == 'user') {
      backgroundColor = Colors.grey[800]!;
    } else if (sender == 'Chill Guy') {
      backgroundColor = Colors.orangeAccent.shade200;
    } else if (sender == 'Emma') {
      backgroundColor = Colors.pinkAccent.shade100;
    } else {
      backgroundColor = Colors.blue.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child:
                sender == 'user'
                    ? const Icon(Icons.person)
                    : const Icon(Icons.face),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageFile != null)
                  Image.file(
                    imageFile!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFFFFFDD0),
                    ), // creamy white
                  ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.volume_up), onPressed: onReadAloud),
        ],
      ),
    );
  }
}

class GeminiAPI {
  static Future<String> getResponse(String message, String botType) async {
    try {
      String personality;
      if (botType == 'Chill Guy') {
        personality = "calm, positive, solution-oriented, 'good bro' vibe";
      } else if (botType == 'Emma') {
        personality = "funny, charming, joyful, kind";
      } else {
        personality = "wise, serious, motivational, big-picture";
      }
      final prompt =
          "You are a $botType AI assistant with a $personality personality. Respond appropriately.\nUser: $message";
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "No reply received.";
    } catch (e) {
      debugPrint("Error calling Vertex AI: $e");
      return "Something went wrong while talking to Gemini.";
    }
  }
}
