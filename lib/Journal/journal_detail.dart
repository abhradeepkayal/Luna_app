// lib/journal_detail.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class JournalDetailPage extends StatelessWidget {
  final String journalId;
  final String journalType;

  const JournalDetailPage({
    Key? key,
    required this.journalId,
    required this.journalType,
  }) : super(key: key);

  static const Color creamyWhite = Color(0xFFFFF9F0);
  static const Color goldenAccent = Color(0xFFFFBF00);
  static const Color darkBackground = Color(0xFF121212);
  static const Color userBubble = goldenAccent;
  static const Color aiBubble = Color(0xFFFF69B4); // Hot Pink for Sura
  static const Color userBorder = Color(0xFFB8860B); // Darker gold
  static const Color aiBorder = Color(0xFF8B004F); // Deep pink border

  static const Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Sad': '😔',
    'Excited': '😄',
    'Neutral': '😐',
    'Tired': '😴',
  };

  Future<DocumentSnapshot> _fetchDoc() {
    final base = FirebaseFirestore.instance;
    if (journalType == 'swifty') {
      return base.collection('journals').doc(journalId).get();
    } else {
      return base.collection('daily_journals').doc(journalId).get().then((
        snap,
      ) async {
        if (snap.exists) return snap;
        return base.collection('journal_history').doc(journalId).get();
      });
    }
  }

  Future<String> _getSwiftySummary(String date, String uid) async {
    final chatSnap =
        await FirebaseFirestore.instance
            .collection('chat_journals')
            .where('uid', isEqualTo: uid)
            .where('date', isEqualTo: date)
            .orderBy('timestamp')
            .get();

    if (chatSnap.docs.isEmpty) return "No conversation found for $date.";

    final buffer = StringBuffer();
    for (var doc in chatSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sender = data['sender'] == 'user' ? 'You' : 'Sura';
      final msg = data['message'] ?? '';
      buffer.writeln('$sender: $msg\n');
    }

    final prompt = '''
Please write a warm, concise daily journal entry summarizing the following conversation:

${buffer.toString()}
''';

    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/text-bison-001',
    );
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text?.trim() ??
        "Sorry, I couldn't generate a summary right now.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        elevation: 6,
        title: const Text(
          "📝 Journal Detail",
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: creamyWhite,
            shadows: [
              Shadow(color: goldenAccent, offset: Offset(1, 1), blurRadius: 2),
            ],
          ),
        ),
        iconTheme: const IconThemeData(
          color: goldenAccent,
          shadows: [
            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 1),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchDoc(),
        builder: (context, docSnap) {
          if (docSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: goldenAccent),
            );
          }

          final doc = docSnap.data;
          if (doc == null || !doc.exists) {
            return const Center(
              child: Text(
                "Journal not found",
                style: TextStyle(
                  color: creamyWhite,
                  fontFamily: 'OpenDyslexic',
                ),
              ),
            );
          }

          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] ?? '';
          final mood = data['mood'] ?? '';
          final emoji = moodEmojis[mood] ?? '';

          if (journalType == 'swifty') {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            return FutureBuilder<String>(
              future: _getSwiftySummary(date, uid),
              builder: (context, sumSnap) {
                if (sumSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: goldenAccent),
                  );
                }

                final summary = sumSnap.data ?? '';
                return _buildSexyContainer(
                  context,
                  date: date,
                  content: summary,
                );
              },
            );
          }

          final content = data['content'] ?? '';
          return _buildSexyContainer(
            context,
            date: date,
            mood: mood,
            emoji: emoji,
            content: content,
            isMarkdown: true,
          );
        },
      ),
    );
  }

  Widget _buildSexyContainer(
    BuildContext context, {
    required String date,
    required String content,
    String mood = '',
    String emoji = '',
    bool isMarkdown = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldenAccent.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 10,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🗓 $date",
              style: const TextStyle(
                fontSize: 18,
                color: creamyWhite,
                fontFamily: 'AtkinsonHyperlegible',
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black45,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            if (mood.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Mood: $emoji $mood",
                style: const TextStyle(
                  fontSize: 16,
                  color: creamyWhite,
                  fontFamily: 'OpenDyslexic',
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      color: Colors.black45,
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child:
                  isMarkdown
                      ? Markdown(
                        data: content,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(
                          p: const TextStyle(
                            fontFamily: 'OpenDyslexic',
                            color: creamyWhite,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        imageBuilder: (uri, title, alt) {
                          if (uri.scheme == 'file') {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Image.file(File(uri.toFilePath())),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Image.network(uri.toString()),
                          );
                        },
                      )
                      : SingleChildScrollView(
                        child: Text(
                          content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: creamyWhite,
                            fontFamily: 'OpenDyslexic',
                            height: 1.6,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
