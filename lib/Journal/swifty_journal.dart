/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

/// --- SWIFTY JOURNAL PAGE ---
class SwiftyJournalPage extends StatefulWidget {
  const SwiftyJournalPage({super.key});

  @override
  State<SwiftyJournalPage> createState() => _SwiftyJournalPageState();
}

class _SwiftyJournalPageState extends State<SwiftyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = false;
  String? _lastUserInput; // for retry

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _isLoading) return;

    setState(() {
      _messages.add("You: $input");
      _isLoading = true;
      _lastUserInput = input;
    });

    _controller.clear();

    final response = await GeminiService.getSuraReply(input);

    setState(() {
      _isLoading = false;
      _messages.add("Sura: $response");
    });

    if (response.startsWith("Oops!")) {
      _showRetrySnackbar();
    }
  }

  void _retryLastMessage() {
    if (_lastUserInput != null) {
      _controller.text = _lastUserInput!;
      _sendMessage();
    }
  }

  void _showRetrySnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Sura didn’t respond 😢"),
        action: SnackBarAction(
          label: "Retry",
          onPressed: _retryLastMessage,
        ),
      ),
    );
  }

  void _saveSwiftyJournal(String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final date = DateFormat('dd-MM-yyyy').format(DateTime.now());

      try {
        await FirebaseService.saveJournal(user.uid, "swifty", content, date);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Journal saved! 📖")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save journal.")),
        );
      }
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
            child: Text("Sura is here to chat 💬", style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.startsWith("You:");
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueGrey : Colors.pinkAccent.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.replaceFirst("You: ", "").replaceFirst("Sura: ", ""),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
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
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final content = _messages.join("\n");
          _saveSwiftyJournal(content);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

/// --- FIREBASE SERVICE ---
class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveJournal(
      String userId, String type, String content, String date) async {
    await _db.collection("journals").add({
      "userId": userId,
      "type": type,
      "content": content,
      "date": date,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getJournals(String userId) {
    return _db
        .collection("journals")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}

/// --- GEMINI SERVICE ---
class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static final String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey";

  static const String _personaPrompt = """
Sura is a light-hearted, cute and compassionate chatbot. She is not an assistant. 
She avoids factual topics and instead responds warmly, playfully or with humor. 
If the user asks anything boring or too serious, she gently changes the topic to something casual like 
'How was your day?' or 'Tell me something fun!'\n\n
You are talking to Sura. Here's the message: 
""";

  static Future<String> getSuraReply(String prompt) async {
    try {
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": _personaPrompt + prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "Oops! Sura is feeling shy right now 😅";
      }
    } catch (e) {
      return "Oops! Something went wrong with Sura 😔";
    }
  }
}*/