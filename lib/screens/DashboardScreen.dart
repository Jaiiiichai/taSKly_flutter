import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskly/models/task_model.dart';
import 'package:taskly/services/task_api_service.dart';
import 'package:taskly/widgets/TaskForm.dart';
import 'package:taskly/widgets/TaskList.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPriority = "All";
  String selectedStatus = "All";
  String dateFilter = "All";
  List<Task> tasks = [];
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  void _showTaskForm() {
    showDialog(
      context: context,
      builder: (context) {
        return Taskform(
          onSave: (title, details, dueDate, priority, status) async {
            final newTask = Task(
              id: UniqueKey().toString(),
              userId: "550e8400-e29b-41d4-a716-446655440001",
              title: title,
              description: details,
              dueDate: dueDate,
              priority: priority,
              status: status, // Use the status from the form
              createdAt: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            );

            try {
              final apiService = TaskApiService();
              await apiService.createTask(newTask);
              await _fetchFilteredTasks(); // Refresh the task list

              Navigator.pop(context);
            } catch (e) {
              print("🔥 Error creating task: $e");
            }
          },
        );
      },
    );
  }

  Future<void> _fetchFilteredTasks() async {
    final apiService = TaskApiService();
    tasks = await apiService.getFilteredTasks(
      selectedPriority,
      selectedStatus,
      dateFilter,
    );
    setState(() {});
  }

  Future<void> _retrieveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      print("Retrieved Token: $token");
    } else {
      print("No token found.");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _retrieveToken();
      _fetchFilteredTasks(); // Fetch tasks initially
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog

                // Delete token and navigate to login screen
                await secureStorage.delete(key: 'auth_token');
                print("✅ Token removed from secure storage.");

                // Navigate to the login screen
                Navigator.pushReplacementNamed(context, "/");
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("TaSKly"),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // Filters Row with Dropdowns
            Container(
              padding: EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filters",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Dropdowns Row
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _buildDropdown(
                            "Priority",
                            selectedPriority,
                            ["All", "Low", "Medium", "High"],
                            (value) {
                              setState(() {
                                selectedPriority = value!;
                                _fetchFilteredTasks(); // Fetch tasks when filter changes
                              });
                            },
                          ),
                        ],
                      ),
                      _buildDropdown(
                        "Status",
                        selectedStatus,
                        ["All", "Completed", "Not Completed"],
                        (value) {
                          setState(() {
                            selectedStatus = value!;
                            _fetchFilteredTasks(); // Fetch tasks when filter changes
                          });
                        },
                      ),
                      _buildDropdown(
                        "Sort By",
                        dateFilter,
                        ["All", "Today", "This week", "This month"],
                        (value) {
                          setState(() {
                            dateFilter = value!;
                            _fetchFilteredTasks(); // Fetch tasks when filter changes
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Task Summary

            // Task List
            Expanded(child: TaskList(tasks: tasks)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskForm,
        backgroundColor: const Color.fromARGB(255, 50, 51, 51),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Reusable Dropdown Widget
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ), // Adds spacing between dropdowns
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.black, fontSize: 12)),
          SizedBox(width: 10), // Spacing between label and dropdown
          Expanded(
            // Ensures dropdown stretches to the right
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color.fromARGB(255, 172, 172, 172),
                  width: 1,
                ), // Black border added here
              ),
              child: DropdownButton<String>(
                value: value,
                items:
                    items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                onChanged: onChanged,
                underline: SizedBox(), // Removes the default dropdown underline
                isExpanded: true, // Makes sure dropdown takes full width
              ),
            ),
          ),
        ],
      ),
    );
  }
}
