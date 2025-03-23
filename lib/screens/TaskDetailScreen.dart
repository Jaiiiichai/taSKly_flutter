import 'package:flutter/material.dart';

class TaskDetailScreen extends StatefulWidget {
  final String title;
  final String details;
  final String dueDate;
  final bool isCompleted;
  final String priority;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailScreen({
    required this.title,
    required this.details,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void deleteTask() {
    widget.onDelete(); // Execute the delete callback

    // Close the current screen
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Task Details"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  widget.details,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Text(
                  "Due Date: ${widget.dueDate}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Text(
                  widget.isCompleted
                      ? "Status: Completed"
                      : "Status: Not Completed",
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.isCompleted ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Priority: ${widget.priority}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: priorityColor(widget.priority),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onEdit,
                      icon: Icon(Icons.edit),
                      label: Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 56, 57, 57),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: deleteTask, // Use deleteTask() here
                      icon: Icon(Icons.delete),
                      label: Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 56, 57, 57),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
