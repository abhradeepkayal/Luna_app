/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neuro_app/Journal/history_page.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Correct import for Quill classes
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'; // Correct import for the toolbar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({super.key});

  @override
  State<DailyJournalPage> createState() => _TodayJournalPageState();
}

class _TodayJournalPageState extends State<DailyJournalPage> {
  late QuillController _controller;
  bool _isLoading = true;
  String selectedMood = '';
  String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
  Timer? _midnightTimer;

  final _editorFocusNode = FocusNode();

  final moods = [
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😄', 'label': 'Excited'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _loadOrCreateTodayJournal();
  }

  Future<void> _loadOrCreateTodayJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('daily_journals')
        .doc("${user.uid}_$today");

    final docSnapshot = await docRef.get();

    if (!mounted) return;

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final content = data['content'];
      _controller = QuillController(
        document: Document.fromJson(content),
        selection: const TextSelection.collapsed(offset: 0),
      );
      selectedMood = data['mood'] ?? '';
    } else {
      _controller = QuillController.basic();
    }

    setState(() {
      _isLoading = false;
    });

    _scheduleMidnightSave();
  }

  void _scheduleMidnightSave() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () async {
      await _saveJournal();

      final newDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      setState(() {
        today = newDate;
        _controller = QuillController.basic();
        selectedMood = '';
      });

      _scheduleMidnightSave();
    });
  }

  Future<void> _saveJournal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final content = _controller.document.toDelta().toJson();
    final docRef = FirebaseFirestore.instance
        .collection('daily_journals')
        .doc("${user.uid}_$today");

    await docRef.set({
      'userId': user.uid,
      'date': today,
      'mood': selectedMood,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal saved ✅')),
    );
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _editorFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today’s Journal"),
            Text("Write freely. Track your mood.",
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text("How are you feeling today?",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: moods.map((mood) {
              final label = "${mood['emoji']} ${mood['label']}";
              final isSelected = selectedMood == label;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.pinkAccent : Colors.grey[800],
                  ),
                  onPressed: () {
                    setState(() {
                      selectedMood = label;
                    });
                  },
                  child: Text(mood['emoji'] as String,
                      style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("📅 $today",
                style: const TextStyle(color: Colors.white70)),
          ),
          // Use the built-in QuillToolbar.basic widget from flutter_quill_extensions
          QuillToolbar.basic(
            controller: _controller,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QuillEditor.basic(
                controller: _controller,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveJournal,
        child: const Icon(Icons.save),
      ),
    );
  }
}*/
