import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final uid = user.uid;

    final swiftyDocs =
        await FirebaseFirestore.instance
            .collection('journals')
            .where('uid', isEqualTo: uid)
            .get();

    final dailyDocs =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('uid', isEqualTo: uid)
            .get();

    final Map<String, Map<String, dynamic>> uniqueJournals = {};

    for (var doc in swiftyDocs.docs) {
      final data = doc.data();
      final key = 'swifty-${data["date"]}';
      if (!uniqueJournals.containsKey(key) ||
          (data['timestamp'] ?? Timestamp(0, 0)).compareTo(
                uniqueJournals[key]!['timestamp'],
              ) >
              0) {
        data['type'] = 'swifty';
        data['id'] = doc.id;
        uniqueJournals[key] = data;
      }
    }

    for (var doc in dailyDocs.docs) {
      final data = doc.data();
      final key = 'daily-${data["date"]}';
      if (!uniqueJournals.containsKey(key) ||
          (data['timestamp'] ?? Timestamp(0, 0)).compareTo(
                uniqueJournals[key]!['timestamp'],
              ) >
              0) {
        data['type'] = 'daily';
        data['id'] = doc.id;
        uniqueJournals[key] = data;
      }
    }

    final all = uniqueJournals.values.toList();

    all.sort((a, b) {
      final t1 = a['timestamp'] as Timestamp?;
      final t2 = b['timestamp'] as Timestamp?;
      if (t1 == null || t2 == null) return 0;
      return t2.compareTo(t1);
    });

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal History"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchJournals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No journal entries found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final journals = snapshot.data!;
          return ListView.builder(
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final entry = journals[index];
              return ListTile(
                leading: const Icon(Icons.book, color: Colors.pinkAccent),
                title: Text(
                  "Journal - ${entry["date"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  entry["type"] == "swifty"
                      ? "Swifty Journal"
                      : "Daily Journal",
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => JournalDetailPage(
                            journalId: entry["id"],
                            journalType: entry["type"],
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
}