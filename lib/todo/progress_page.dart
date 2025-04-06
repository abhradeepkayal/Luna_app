

import 'package:flutter/material.dart';
import 'task_model.dart';
import 'task_firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


const deepGold = Color(0xFFFFBF00);

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TaskFirestoreService _firestoreService = TaskFirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "📈 Progress",
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: Color(0xFFFFF9F0),
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 3, color: deepGold),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Error loading tasks: ${snapshot.error}');
            return Center(
              child: Text(
                "Error loading tasks: ${snapshot.error}",
                style: const TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Color(0xFFFFF9F0),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data ?? [];
          final userTasks = tasks.where((task) => task.uid == _userId).toList();
          final int total = userTasks.length;
          final int completed =
              userTasks.where((task) => task.isCompleted).length;
          final double progressValue = total == 0 ? 0.0 : completed / total;
          final int percentage = (progressValue * 100).toInt();
          final int points = completed * 5;

          debugPrint(
            'Total: $total, Completed: $completed, Percentage: $percentage',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      "✅ Completed",
                      "$completed / $total",
                      Colors.greenAccent,
                    ),
                    _buildStatCard("🏆 Points", "$points", Colors.amberAccent),
                  ],
                ),
                const SizedBox(height: 30),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: deepGold, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: deepGold.withOpacity(0.5),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Progress",
                          style: TextStyle(
                            fontFamily: 'AtkinsonHyperlegible',
                            color: Color(0xFFFFF9F0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progressValue,
                          color: Colors.lightBlueAccent,
                          backgroundColor: Colors.white24,
                          minHeight: 12,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            "$percentage% Completed",
                            style: const TextStyle(
                              fontFamily: 'AtkinsonHyperlegible',
                              color: Colors.lightBlueAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                const Text(
                  "🚀 Keep going! You're doing great!",
                  style: TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    color: Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deepGold, width: 1),
        boxShadow: [
          BoxShadow(
            color: deepGold.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'AtkinsonHyperlegible',
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'AtkinsonHyperlegible',
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
