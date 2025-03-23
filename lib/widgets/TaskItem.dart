import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskly/screens/TaskDetailScreen.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final String id;
  final String userId;
  final bool isCompleted;
  final String priority;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final ValueChanged<bool?> onCheckboxChanged;

  const TaskItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.priority,
    required this.onEdit,
    required this.onDelete,

    required this.onCheckboxChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Checkbox(value: isCompleted, onChanged: onCheckboxChanged),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor(priority).withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                priority.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: priorityColor(priority),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? Colors.grey : Colors.black,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Due: ${DateFormat('MMMM d, y h:mm a').format(DateTime.parse(dueDate))}",
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? Colors.grey : Colors.black,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 56, 57, 57),
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 56, 57, 57),
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          print(
            "Tapped Task - Id : $id, Title: $title, Priority: $priority, Due: $dueDate, Status: ${isCompleted ? "Completed" : "Not Completed"}",
          );

          final updatedTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TaskDetailScreen(
                    title: title,
                    details: description,
                    dueDate: dueDate,
                    isCompleted: isCompleted,
                    priority: priority,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
            ),
          );

          if (updatedTask != null) {
            onEdit(); // Refresh the task list if an update occurs
          }
        },
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
