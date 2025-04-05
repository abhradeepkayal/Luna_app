import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// Removed unused Cloud Functions import since we now use Vertex AI.
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

  String _botType = 'funny';
  bool _isListening = false;
  bool _showBotList = false;
  bool _isImageLoading = false;

  final List<String> _botTypes = [
    'funny',
    'wise',
    'strict',
    'sarcastic',
    'friendly',
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final userMessage = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: userMessage, sender: 'user'));
      _controller.clear();
    });
    _getBotResponse(userMessage);
  }

  Future<void> _getBotResponse(String message) async {
    String response = await GeminiAPI.getResponse(message, _botType);
    setState(() {
      _messages.add(ChatMessage(text: response, sender: 'bot'));
    });
    _saveMessageToFirestore(response, 'bot');
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
      debugPrint("Picked image: ${pickedFile.path}");
    }

    setState(() => _isImageLoading = false);
  }

  void _switchBotType(String type) {
    setState(() {
      _botType = type;
      _messages.clear();
      _messages.add(
        ChatMessage(text: "I'm now $_botType bot! Let's chat.", sender: 'bot'),
      );
      _showBotList = false;
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
            children: [
              Text('Chatbot: $_botType'),
              const Icon(Icons.switch_left),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (_showBotList)
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Wrap(
                spacing: 8,
                children:
                    _botTypes
                        .map(
                          (type) => ElevatedButton(
                            onPressed: () => _switchBotType(type),
                            child: Text(type),
                          ),
                        )
                        .toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isImageLoading) const CircularProgressIndicator(),
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
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => _readAloud(_controller.text),
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

  const ChatMessage({super.key, required this.text, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sender == 'user' ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (sender != 'user') const CircleAvatar(child: Icon(Icons.face)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class GeminiAPI {
  static Future<String> getResponse(String message, String botType) async {
    try {
      final prompt =
          "You are a $botType AI assistant. Respond appropriately.\nUser: $message";
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
