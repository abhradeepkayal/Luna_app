import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

/// FirebaseService: Saves journal entries to Firestore.
/// Update this as needed for your Firestore structure.
class FirebaseService {
  static Future<void> saveJournal(
    String uid,
    String journalType,
    String content,
    String date,
  ) async {
    await FirebaseFirestore.instance.collection('journals').add({
      'uid': uid,
      'journalType': journalType,
      'content': content,
      'date': date,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

/// GeminiService: Uses Firebase Vertex AI to generate Sura's reply.
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

/// SwiftyJournalPage: Chat UI with Sura.
class SwiftyJournalPage extends StatefulWidget {
  const SwiftyJournalPage({super.key});

  @override
  State<SwiftyJournalPage> createState() => _SwiftyJournalPageState();
}

class _SwiftyJournalPageState extends State<SwiftyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  // Sends the user's message to Sura and displays Sura's reply.
  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add("You: $input");
    });

    _controller.clear();

    // Retrieve Sura's reply using Firebase Vertex AI.
    final response = await GeminiService.getSuraReply(input);

    setState(() {
      _messages.add("Sura: $response");
    });
  }

  // Saves the conversation to Firestore.
  void _saveSwiftyJournal(String content) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      FirebaseService.saveJournal(user.uid, "swifty", content, date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Swifty Journal"),
            Text(
              "Sura: Your Cute & Insightful Journaling Companion! 📝💖",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Sura is here to chat 💬",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.startsWith("You:")
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          message.startsWith("You:")
                              ? Colors.blueGrey
                              : Colors.pinkAccent.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message
                          .replaceFirst("You: ", "")
                          .replaceFirst("Sura: ", ""),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Talk to Sura...",
                    filled: true,
                    fillColor: Colors.white24,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save the complete conversation.
          final content = _messages.join("\n");
          _saveSwiftyJournal(content);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: SwiftyJournalPage()));
}
