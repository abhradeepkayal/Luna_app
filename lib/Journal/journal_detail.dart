import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalDetailPage extends StatelessWidget {
  final String journalId;
  final String journalType;

  const JournalDetailPage({
    super.key,
    required this.journalId,
    required this.journalType,
  });

  @override
  Widget build(BuildContext context) {
    // Choose the collection based on the journal type.
    final String collectionName =
        journalType == 'swifty' ? 'journals' : 'daily_journals';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Detail"),
        backgroundColor: Colors.black,
      ),
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
          final String content = data['content'] as String? ?? '';
          final String date = data['date'] as String? ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: const TextStyle(color: Colors.white),
                    ),
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
