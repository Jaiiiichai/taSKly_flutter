import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskly/models/task_model.dart'; // Import the Task model

class TaskApiService {
  static const String baseUrl =
      "http://152.42.161.12"; // Replace with your API endpoint

  // Fetch all tasks from API
  Future<List<Task>> getTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        print("❌ No token found!");
        throw Exception("Authentication token is missing.");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/api/tasks"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print("✅ Fetched tasks: ${response.body}");

        final data = json.decode(response.body);
        if (data.containsKey("tasks")) {
          return (data["tasks"] as List)
              .map((json) => Task.fromMap(json))
              .toList();
        } else {
          throw Exception("Invalid API response format.");
        }
      } else {
        print("❌ Fetching tasks failed: ${response.body}");
        throw Exception("Failed to load tasks");
      }
    } catch (e) {
      print("🔥 Error in getTasks(): $e");
      rethrow;
    }
  }

  // 🔹 Fetch & Filter Tasks
  Future<List<Task>> getFilteredTasks(
    String priority,
    String status,
    String dateFilter,
  ) async {
    List<Task> allTasks = await getTasks();
    print(
      "🔍 Filtering tasks: Priority = $priority, Status = $status, Date = $dateFilter",
    );

    List<Task> filteredTasks = List.from(allTasks);

    // ✅ Filter by Priority
    if (priority != "All") {
      filteredTasks =
          filteredTasks
              .where(
                (task) => task.priority.toLowerCase() == priority.toLowerCase(),
              )
              .toList();
    }

    // ✅ Filter by Status
    if (status != "All") {
      bool isCompleted = status == "Completed";
      filteredTasks =
          filteredTasks.where((task) => task.status == isCompleted).toList();
    }

    // ✅ Filter by Date Range
    DateTime now = DateTime.now();
    filteredTasks =
        filteredTasks.where((task) {
          DateTime dueDate = DateTime.parse(task.dueDate);

          if (dateFilter == "Today") {
            return dueDate.year == now.year &&
                dueDate.month == now.month &&
                dueDate.day == now.day;
          } else if (dateFilter == "This week") {
            DateTime startOfWeek = now.subtract(
              Duration(days: now.weekday - 1),
            );
            DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
            return dueDate.isAfter(startOfWeek) && dueDate.isBefore(endOfWeek);
          } else if (dateFilter == "This month") {
            return dueDate.year == now.year && dueDate.month == now.month;
          }
          return true;
        }).toList();

    print("📋 Filtered Tasks Count: ${filteredTasks.length}");
    return filteredTasks;
  }

  // 🔹 Create Task
  Future<Task> createTask(Task task) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("❌ Authentication token is missing.");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/tasks"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": task.title,
          "description": task.description,
          "due_date": task.dueDate,
          "priority": task.priority.toLowerCase(),
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Task Created: ${response.body}");
        return Task.fromJson(response.body);
      } else {
        throw Exception("❌ Failed to create task: ${response.body}");
      }
    } catch (e) {
      print("🔥 Error in createTask(): $e");
      rethrow;
    }
  }

  // 🔹 Update Task
  Future<Task> updateTask(Task task) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse("$baseUrl/api/tasks/${task.id}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": task.title,
          "description": task.description,
          "due_date": task.dueDate,
          "priority": task.priority.toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(response.body);
      } else {
        throw Exception("❌ Failed to update task");
      }
    } catch (e) {
      print("🔥 Error in updateTask(): $e");
      rethrow;
    }
  }

  // 🔹 Delete Task
  Future<bool> deleteTask(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse("$baseUrl/api/tasks/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Task deleted successfully: $id");
        return true;
      } else {
        throw Exception("❌ Failed to delete task");
      }
    } catch (e) {
      print("🔥 Error in deleteTask(): $e");
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login");
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register");
    }
  }

  // Logout

  // 🔹 Logout
  Future<bool> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        print("❌ No token found! Already logged out.");
        return true; // No token means already logged out
      }

      print("🔑 Logging out with token: $token");

      final response = await http.post(
        Uri.parse("$baseUrl/api/logout"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token'); // Remove token
        print("✅ Logout successful! Token removed.");
        return true;
      } else {
        print("❌ Logout failed: ${response.body}");
        throw Exception("Failed to logout");
      }
    } catch (e) {
      print("🔥 Error in logout(): $e");
      return false;
    }
  }
}
