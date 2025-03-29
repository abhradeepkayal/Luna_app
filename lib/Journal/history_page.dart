/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuro_app/Journal/journal_detail.dart';
import 'package:rxdart/rxdart.dart'; // ✅ needed for Rx.combineLatest2

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Stream<List<Map<String, dynamic>>> _getJournalEntries() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final dailyStream = FirebaseFirestore.instance
        .collection('daily_journals')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'date': data['date'] ?? '',
                'type': 'daily',
                'mood': data['mood'] ?? '',
                'content': data['content'],
              };
            }).toList());

    final swiftyStream = FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'swifty')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'date': data['date'] ?? '',
                'type': 'swifty',
                'content': data['content'],
              };
            }).toList());

    // ✅ Use Rx.combineLatest2 from rxdart
    return Rx.combineLatest2<List<Map<String, dynamic>>, List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
      dailyStream,
      swiftyStream,
      (a, b) {
        final all = [...a, ...b];
        all.sort((x, y) => y['date'].compareTo(x['date']));
        return all;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal History"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(child: Text("No journals yet 📝"));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final type = entry['type'] as String;
              final date = entry['date'] as String;
              final mood = entry['mood'] as String?;
              final content = entry['content'];

              return ListTile(
                leading: Icon(
                  Icons.book,
                  color: type == "swifty" ? Colors.pinkAccent : Colors.tealAccent,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Journal - $date",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (type == "daily" && mood != null && mood.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mood,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  type == "swifty" ? "Swifty Journal" : "Daily Journal",
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalDetailPage(
                        content: content,
                        date: date,
                        type: type,
                        mood: mood,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}*/