import 'package:flutter/foundation.dart';
import 'package:taskly/models/task_model.dart'; // Make sure to import your Task class

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // Notify listeners about the change
  }

  // Update an existing task
  void updateTask(String id, Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Remove a task
  void removeTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners(); // Notify listeners about the change
  }

  // Toggle task status
  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].status = !_tasks[index].status; // Toggle the status
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Load tasks from a source (e.g., API or local storage)
  void loadTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners(); // Notify listeners about the change
  }
}
