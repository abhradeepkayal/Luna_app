

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'journal_detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  static const Color bgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentColor = Color(0xFFFFBF00);
  static const Color textColor = Color(0xFFFAF3E0);

  Future<List<Map<String, dynamic>>> _fetchJournals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final uid = user.uid;

    final swiftySnap =
        await FirebaseFirestore.instance
            .collection('journals')
            .where('uid', isEqualTo: uid)
            .get();
    final dailyTodaySnap =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('uid', isEqualTo: uid)
            .get();
    final dailyArchivedSnap =
        await FirebaseFirestore.instance
            .collection('journal_history')
            .where('uid', isEqualTo: uid)
            .get();

    final unique = <String, Map<String, dynamic>>{};
    void addDocs(List<QueryDocumentSnapshot> docs, String type) {
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data['timestamp'] as Timestamp? ?? Timestamp(0, 0);
        final dayKey = DateFormat('yyyy-MM-dd').format(ts.toDate());
        final key = '$type-$dayKey';
        if (!unique.containsKey(key) ||
            ts.compareTo(unique[key]!['timestamp'] as Timestamp) > 0) {
          unique[key] = {...data, 'id': doc.id, 'type': type};
        }
      }
    }

    addDocs(swiftySnap.docs, 'swifty');
    addDocs(dailyArchivedSnap.docs, 'daily');
    addDocs(dailyTodaySnap.docs, 'daily');

    final list = unique.values.toList();
    list.sort((a, b) {
      final t1 = a['timestamp'] as Timestamp;
      final t2 = b['timestamp'] as Timestamp;
      return t2.compareTo(t1);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Journal History',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentColor,
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchJournals(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            );
          }
          final data = snap.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                'No journal entries found.',
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final entry = data[i];
              final ts = entry['timestamp'] as Timestamp;
              final dateTime = ts.toDate().toLocal();
              final displayDate = DateFormat(
                'yyyy-MM-dd – hh:mm a',
              ).format(dateTime);
              final isSwifty = entry['type'] == 'swifty';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => JournalDetailPage(
                            journalId: entry['id'],
                            journalType: entry['type'],
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(3, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isSwifty ? Icons.chat_bubble : Icons.book,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayDate,
                              style: const TextStyle(
                                fontFamily: 'AtkinsonHyperlegible',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSwifty ? 'Swifty Journal' : 'Daily Journal',
                              style: const TextStyle(
                                fontFamily: 'OpenDyslexic',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                     
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
