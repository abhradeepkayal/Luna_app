import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _controller = TextEditingController();
  final List<String> tasks = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<String>> _generateTaskSuggestions(String input) async {
    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'models/gemini-2.0-flash-001',
      );
      final response = await model.generateContent([Content.text(input)]);
      return response.text?.split('\n') ?? ['No suggestions available.'];
    } catch (e) {
      print('Error generating task suggestions: $e');
      return ['Error generating suggestions.'];
    }
  }

  void _addTaskWithAI() async {
    final input = _controller.text.isEmpty 
        ? 'Suggest 3 tasks for my day'
        : _controller.text;
    
    final suggestions = await _generateTaskSuggestions(input);
    setState(() {
      tasks.addAll(suggestions.where((task) => task.trim().isNotEmpty));
    });

    if (_userId != null) {
      for (final task in suggestions) {
        if (task.trim().isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('tasks')
              .add({
            'task': task.trim(),
            'createdAt': Timestamp.now(),
            'uid': _userId,
          });
        }
      }
    }

    _controller.clear();
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI-Powered To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your task prompt (e.g., "Suggest workout routines")',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTaskWithAI,
            child: Text('Generate Tasks with AI'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              }),
          ),
        ],
      ),
    );
  }
}