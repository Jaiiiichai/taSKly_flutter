import 'dart:convert';

class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  bool status;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.status = false, // Default value
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Task to Map (for JSON conversion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert Map (JSON) to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['due_date'] ?? '',
      priority: map['priority'] ?? 'low',
      status: map['status'] ?? false, // Ensure it gets a default boolean value
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  // Convert Task to JSON
  String toJson() => json.encode(toMap());

  // Convert JSON to Task object
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
