class Task {
  String id;
  String title;
  bool isCompleted;
  List<Task> subtasks;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subtasks = const [],
  });

  factory Task.fromMap(Map<String, dynamic> map, String docId) {
    List<Task> subtaskList = [];
    if (map['subtasks'] != null) {
      subtaskList = (map['subtasks'] as List)
          .map((subtask) => Task.fromMap(subtask as Map<String, dynamic>, ''))
          .toList();
    }

    return Task(
      id: docId,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: subtaskList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
    };
  }
}
