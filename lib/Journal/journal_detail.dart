import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class JournalDetailPage extends StatelessWidget {
  final String journalId;
  final String journalType;

  const JournalDetailPage({
    super.key,
    required this.journalId,
    required this.journalType,
  });

  static const Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Sad': '😔',
    'Excited': '😄',
    'Neutral': '😐',
    'Tired': '😴',
    // Add more moods here if needed
  };

  @override
  Widget build(BuildContext context) {
    final String collectionName =
        journalType == 'swifty' ? 'journals' : 'daily_journals';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Detail"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection(collectionName)
                .doc(journalId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Journal not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String content = data['content'] ?? '';
          final String date = data['date'] ?? '';
          final String mood = data['mood'] ?? '';
          final String emoji = moodEmojis[mood] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🗓 $date",
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                if (mood.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    "Mood: $emoji $mood",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: Markdown(
                    data: content,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(p: const TextStyle(color: Colors.white)),
                    imageBuilder: (uri, title, alt) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(uri.toString()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}