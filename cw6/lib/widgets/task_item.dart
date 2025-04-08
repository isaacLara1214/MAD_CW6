import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final DatabaseService databaseService;

  const TaskItem({
    super.key,
    required this.task,
    required this.databaseService,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _expanded = false;
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: widget.task.isCompleted,
              onChanged: (value) {
                widget.databaseService.updateTaskCompletion(
                  widget.task.id,
                  value ?? false,
                );
              },
            ),
            title: Text(
              widget.task.title,
              style: TextStyle(
                decoration:
                    widget.task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    widget.databaseService.deleteTask(widget.task.id);
                  },
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: 'Add subtask',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_subtaskController.text.isNotEmpty) {
                        widget.databaseService.addSubtask(
                          widget.task.id,
                          _subtaskController.text,
                        );
                        _subtaskController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
            if (widget.task.subtasks.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.task.subtasks.length,
                itemBuilder: (context, index) {
                  final subtask = widget.task.subtasks[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                    leading: Checkbox(
                      value: subtask.isCompleted,
                      onChanged: (value) {
                        widget.databaseService.updateSubtaskCompletion(
                          widget.task.id,
                          index,
                          value ?? false,
                        );
                      },
                    ),
                    title: Text(
                      subtask.title,
                      style: TextStyle(
                        decoration: subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        widget.databaseService
                            .deleteSubtask(widget.task.id, index);
                      },
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
