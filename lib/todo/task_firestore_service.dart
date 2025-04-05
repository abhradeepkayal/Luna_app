import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskFirestoreService {
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await tasksCollection.doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> updateTaskWithSubtasks(String taskId, List<Map<String, dynamic>> subtasks) async {
    await tasksCollection.doc(taskId).update({
      'subtasks': subtasks,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getTasksStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return tasksCollection
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
      }).toList();
    });
  }
}