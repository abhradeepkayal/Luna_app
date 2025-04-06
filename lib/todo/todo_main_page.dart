import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_input_widget.dart';
import 'progress_page.dart';
import 'task_model.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define the deep golden accent (#FFBF00).
const deepGold = Color(0xFFFFBF00);

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
    String prompt =
        '''Summarize the following to-do list into a concise daily overview.
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
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: deepGold, width: 1),
              ),
              title: const Text(
                "🧠 AI Summary",
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Color(0xFFFFF9F0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: deepGold,
                    ),
                  ],
                ),
              ),
              content: Text(
                summary ?? "No summary available.",
                style: const TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Colors.white70,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      color: deepGold,
                    ),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: deepGold, width: 1),
              ),
              title: const Text(
                "🧠 AI Summary",
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Color(0xFFFFF9F0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: deepGold,
                    ),
                  ],
                ),
              ),
              content: Text(
                "Error generating summary: $e",
                style: const TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Colors.white70,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      color: deepGold,
                    ),
                  ),
                ),
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
            List<Task> firebaseTasks =
                snapshot.docs
                    .map(
                      (doc) => Task.fromMap(
                        doc.data() as Map<String, dynamic>,
                        id: doc.id,
                      ),
                    )
                    .toList();
            setState(() {
              tasks = firebaseTasks;
            });
          });
    }
  }

  // Helper widget for app bar icons with a simple border effect.
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: deepGold, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        color: const Color(0xFFFFF9F0),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting =
        DateTime.now().hour < 12
            ? "Good morning"
            : DateTime.now().hour < 18
            ? "Good afternoon"
            : "Good evening";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 8,
        centerTitle: true,
        title: const Text(
          'To-Do List',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: Color(0xFFFFF9F0),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(2, 2), blurRadius: 4, color: deepGold),
            ],
          ),
        ),
        actions: [
          _buildIconButton(
            icon: Icons.summarize,
            tooltip: 'AI Daily Summary',
            onPressed: _showDailySummary,
          ),
          _buildIconButton(
            icon: Icons.show_chart,
            tooltip: 'View Progress',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressPage()),
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
                // Header Section with an elevated 3D effect.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: deepGold.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(color: deepGold, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting!',
                        style: const TextStyle(
                          fontFamily: 'OpenDyslexic',
                          fontSize: 20,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
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
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMEEEEd().format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: 'AtkinsonHyperlegible',
                          fontSize: 16,
                          color: const Color(0xFFFFF9F0).withOpacity(0.8),
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Task Input and List Section with a raised card effect.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: deepGold.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(color: deepGold, width: 1),
                  ),
                  child: TaskInputWidget(
                    onTaskListChanged: updateTasks,
                    selectedCategory: selectedCategory,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
