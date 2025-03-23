// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taskly/services/task_api_service.dart'; // API Service for fetching tasks
import 'package:taskly/widgets/TaskForm.dart';
import 'package:taskly/widgets/TaskItem.dart';
import 'package:taskly/models/task_model.dart';

class TaskList extends StatefulWidget {
  List<Task> tasks;

  TaskList({super.key, required this.tasks});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> _tasks = [];
  late Timer _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks); // ✅ Initialize from widget
    _fetchTasks(); // ✅ Fetch tasks initially

    // ✅ Fetch tasks every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchTasks();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // ✅ Stop the timer when widget is disposed
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    try {
      final apiService = TaskApiService();
      List<Task> fetchedTasks = await apiService.getTasks(); // ✅ Fetch tasks

      if (mounted) {
        setState(() {
          _tasks = fetchedTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching tasks: $e");
    }
  }

  void _openAddModal(BuildContext context, {Task? task, int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        return Taskform(
          initialTitle: task?.title ?? '',
          initialDetails: task?.description ?? '',
          initialDueDate: task?.dueDate ?? '',
          initialPriority: _validatePriority(task?.priority),
          onSave: (title, description, dueDate, priority, status) async {
            final updatedTask = Task(
              id: task?.id ?? UniqueKey().toString(),
              userId: task?.userId ?? '550e8400-e29b-41d4-a716-446655440001',
              title: title,
              description: description,
              dueDate: dueDate,
              priority: priority,
              status: status,
              createdAt:
                  task?.createdAt ?? DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            );

            setState(() {
              if (index != null) {
                _tasks[index] = updatedTask;
              } else {
                final apiService = TaskApiService();

                apiService.updateTask(updatedTask);
              }
            });
          },
        );
      },
    );
  }

  String _validatePriority(String? priority) {
    const validPriorities = ['High', 'Medium', 'Low'];
    return validPriorities.contains(priority) ? priority! : 'Low';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator()); // ✅ Show loading
    }

    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _tasks.removeAt(oldIndex);
          _tasks.insert(newIndex, item);
        });
      },
      children:
          _tasks
              .map(
                (task) => TaskItem(
                  key: ValueKey(task.id),
                  id: task.id,
                  userId: task.userId,
                  title: task.title,
                  description: task.description,
                  dueDate: task.dueDate,
                  isCompleted: task.status,
                  priority: task.priority,
                  onEdit: () => _openAddModal(context, task: task),
                  onDelete: () async {
                    final apiService = TaskApiService();

                    try {
                      bool isDeleted = await apiService.deleteTask(task.id);
                      if (isDeleted) {
                        setState(() {
                          _tasks.removeWhere((t) => t.id == task.id);
                        });
                        print("✅ Task deleted successfully: ${task.id}");
                      } else {
                        print("❌ Failed to delete task from API");
                      }
                    } catch (e) {
                      print("❌ Error deleting task: $e");
                    }
                  },
                  onCheckboxChanged: (value) {
                    setState(() {
                      task.status = value!;
                    });
                  },
                ),
              )
              .toList(),
    );
  }
}
