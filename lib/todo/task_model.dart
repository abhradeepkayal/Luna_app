import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  String title;
  String category;
  final DateTime date;
  bool isCompleted;
  final String uid;
  List<Map<String, dynamic>> subtasks; // Each subtask is a map with keys 'title' and 'isCompleted'

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.category = 'All',
    this.isCompleted = false,
    required this.uid,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'uid': uid,
      'subtasks': subtasks,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    // Support both String and Timestamp for the date field.
    if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date'] as String);
    } else if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }
    
    // Process the subtasks field: It may be a List<String> or a List<Map<String, dynamic>>
    List<Map<String, dynamic>> processedSubtasks = [];
    if (map['subtasks'] is List) {
      final rawSubtasks = map['subtasks'] as List;
      processedSubtasks = rawSubtasks.map((e) {
        if (e is Map<String, dynamic>) {
          return e;
        } else if (e is String) {
          return {'title': e, 'isCompleted': false};
        } else {
          return <String, dynamic>{};
        }
      }).toList();
    }
    
    return Task(
      id: id ?? (map['id'] as String? ?? ''),
      title: map['title'] as String,
      category: map['category'] as String? ?? 'All',
      date: parsedDate,
      isCompleted: map['isCompleted'] as bool? ?? false,
      uid: map['uid'] as String,
      subtasks: processedSubtasks,
    );
  }
}