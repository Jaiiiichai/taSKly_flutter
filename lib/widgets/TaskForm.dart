import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskly/widgets/CustomButton.dart';

class Taskform extends StatefulWidget {
  final Function(String, String, String, String, bool) onSave;
  final String? initialTitle;
  final String? initialDetails;
  final String? initialDueDate;
  final String? initialPriority;
  final bool? initialStatus;

  const Taskform({
    required this.onSave,
    this.initialTitle,
    this.initialDetails,
    this.initialDueDate,
    this.initialPriority,
    this.initialStatus,
    super.key,
  });

  @override
  State<Taskform> createState() => _TaskformState();
}

class _TaskformState extends State<Taskform> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _dateTimeController;
  String? _selectedPriority;
  late bool _status; // ✅ Added this

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _detailsController = TextEditingController(text: widget.initialDetails);
    _dateTimeController = TextEditingController(text: widget.initialDueDate);
    _selectedPriority = widget.initialPriority;
    _status = widget.initialStatus ?? false; // ✅ Initialize _status
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Add/Edit Task"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Task Name"),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please enter a task name"
                              : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(labelText: "Task Details"),
                  keyboardType: TextInputType.multiline,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please enter task details"
                              : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dateTimeController,
                  decoration: InputDecoration(
                    labelText: "Due Date & Time",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDateTime(context),
                    ),
                  ),
                  readOnly: true,
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? "Please select a due date & time"
                              : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Priority Level",
                  ),
                  value: _selectedPriority,
                  items:
                      ["High", "Medium", "Low"].map((priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null
                              ? "Please select a priority level"
                              : null,
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text("Completed"),
                  value: _status,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _status = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        CustomButton(
          onPressed: () => Navigator.of(context).pop(),
          text: "Cancel",
          color: const Color.fromARGB(255, 147, 147, 147),
          width: 70,
          height: 50,
        ),
        CustomButton(
          text: "Save",
          width: 70,
          color: const Color.fromARGB(255, 71, 70, 70),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _titleController.text,
                _detailsController.text,
                _dateTimeController.text,
                _selectedPriority!,
                _status, // ✅ Pass status correctly
              );
              print("✅ Task added successfully: ${_titleController.text}");
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDateTime = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(finalDateTime);

        setState(() {
          _dateTimeController.text = formattedDateTime;
        });
      }
    }
  }
}
