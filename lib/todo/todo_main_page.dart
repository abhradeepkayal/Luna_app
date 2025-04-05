import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_input_widget.dart';
import 'progress_page.dart';
import 'task_model.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoMainPage extends StatefulWidget {
  const TodoMainPage({super.key});

  @override
  State<TodoMainPage> createState() => _TodoMainPageState();
}

class _TodoMainPageState extends State<TodoMainPage> {
  List<Task> tasks = [];
  String selectedCategory = 'All';

  void updateTasks(List<Task> updatedTasks) {
    setState(() {
      tasks = updatedTasks;
    });
  }

  void _showDailySummary() async {
    // Build a prompt using all task titles.
    String taskTitles = tasks.map((t) => t.title).join(', ');
    String prompt = '''Summarize the following to-do list into a concise daily overview.
     Keep the language clear and to the point. Avoid using bold text or any extra formatting.
     Focus on key tasks and group similar items if applicable.: $taskTitles''';
    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([Content.text(prompt)]);
      final summary = response.text;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("🧠 AI Summary", style: TextStyle(color: Colors.white)),
          content: Text(summary ?? "No summary available.", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.amberAccent)),
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text("🧠 AI Summary", style: TextStyle(color: Colors.white)),
          content: Text("Error generating summary: $e", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.amberAccent)),
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Filter tasks by the current user's UID for uniformity across devices.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        List<Task> firebaseTasks = snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
            .toList();
        setState(() {
          tasks = firebaseTasks;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = DateTime.now().hour < 12
        ? "Good morning"
        : DateTime.now().hour < 18
            ? "Good afternoon"
            : "Good evening";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'NeuroApp',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: Color(0xFFFFF9F0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            color: const Color(0xFFFFF9F0),
            tooltip: 'AI Daily Summary',
            onPressed: _showDailySummary,
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            color: const Color(0xFFFFF9F0),
            tooltip: 'View Progress',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Everything except the AppBar is scrollable.
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting!',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Daily Planner',
                        style: TextStyle(
                          fontFamily: 'AtkinsonHyperlegible',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFF9F0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMEEEEd().format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFFFF9F0).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Task Input and List Section
                TaskInputWidget(
                  onTaskListChanged: updateTasks,
                  selectedCategory: selectedCategory,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}