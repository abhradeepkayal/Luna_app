import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_detail.dart'; // Import your journal detail page

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Fetches journal entries from both 'daily_journals' and 'journals' collections
  Future<List<Map<String, dynamic>>> _fetchJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    final uid = user.uid;

    // Query daily journals
    final dailyQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('uid', isEqualTo: uid)
            .get();

    // Query swifty journals
    final swiftyQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('journals')
            .where('uid', isEqualTo: uid)
            .get();

    List<Map<String, dynamic>> journals = [];

    // Process daily journals: assign type and include document id.
    for (var doc in dailyQuerySnapshot.docs) {
      final data = doc.data();
      data['type'] = 'daily';
      data['id'] = doc.id;
      journals.add(data);
    }

    // Process swifty journals: assign type and include document id.
    for (var doc in swiftyQuerySnapshot.docs) {
      final data = doc.data();
      data['type'] = 'swifty';
      data['id'] = doc.id;
      journals.add(data);
    }

    // Sort the journals by server-generated timestamp (newest first)
    journals.sort((a, b) {
      final t1 = a['timestamp'] as Timestamp?;
      final t2 = b['timestamp'] as Timestamp?;
      if (t1 == null || t2 == null) return 0;
      return t2.compareTo(t1);
    });

    return journals;
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
                leading: Icon(
                  Icons.book,
                  color:
                      entry["type"] == "swifty"
                          ? Colors.pinkAccent
                          : Colors.tealAccent,
                ),
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
                  // Navigate to the journal detail page with document id and type
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => JournalDetailPage(
                            journalId: entry["id"] as String,
                            journalType: entry["type"] as String,
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
