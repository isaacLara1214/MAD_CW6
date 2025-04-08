import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class DatabaseService {
  final String uid;
  final CollectionReference tasksCollection;

  DatabaseService({required this.uid})
      : tasksCollection =
            FirebaseFirestore.instance.collection('users/$uid/tasks');

  Stream<List<Task>> get tasks {
    return tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addTask(String title) {
    return tasksCollection.add({
      'title': title,
      'isCompleted': false,
      'subtasks': [],
    });
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) {
    return tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String taskId) {
    return tasksCollection.doc(taskId).delete();
  }

  Future<void> addSubtask(String parentTaskId, String title) async {
    DocumentSnapshot doc = await tasksCollection.doc(parentTaskId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> subtasks = data['subtasks'] ?? [];

    subtasks.add({
      'title': title,
      'isCompleted': false,
      'subtasks': [],
    });

    return tasksCollection.doc(parentTaskId).update({'subtasks': subtasks});
  }

  Future<void> updateSubtaskCompletion(
      String parentTaskId, int index, bool isCompleted) async {
    DocumentSnapshot doc = await tasksCollection.doc(parentTaskId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> subtasks = data['subtasks'] ?? [];

    if (index < subtasks.length) {
      subtasks[index]['isCompleted'] = isCompleted;
      return tasksCollection.doc(parentTaskId).update({'subtasks': subtasks});
    }
  }

  Future<void> deleteSubtask(String parentTaskId, int index) async {
    DocumentSnapshot doc = await tasksCollection.doc(parentTaskId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> subtasks = data['subtasks'] ?? [];

    if (index < subtasks.length) {
      subtasks.removeAt(index);
      return tasksCollection.doc(parentTaskId).update({'subtasks': subtasks});
    }
  }
}
