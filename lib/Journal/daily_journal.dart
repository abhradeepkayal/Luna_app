import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({super.key});

  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedMood = '';

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😄', 'label': 'Excited'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  Future<void> _saveJournal() async {
    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String journalContent = _controller.text;

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('daily_journals').add({
      'uid': user?.uid ?? 'anonymous',
      'date': today,
      'mood': selectedMood,
      'content': journalContent,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Journal"),
            Text(
              "Capture thoughts and track your progress!",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "How are you feeling today?",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  moods.map((mood) {
                    return IconButton(
                      icon: Text(
                        mood['emoji'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedMood = mood['label'];
                        });
                      },
                    );
                  }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "📅 $today",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Write your thoughts here...",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveJournal,
        child: const Icon(Icons.save),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(
      home: DailyJournalPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
