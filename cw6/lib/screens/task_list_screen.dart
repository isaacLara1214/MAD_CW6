import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const TaskListScreen({
    super.key,
    required this.authService,
    required this.databaseService,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      widget.databaseService.addTask(_taskController.text);
                      _taskController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: widget.databaseService.tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add some!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskItem(
                      task: tasks[index],
                      databaseService: widget.databaseService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
