import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  final List<Task> tasks;
  final Task? existingTask;

  AddTaskScreen({required this.tasks, this.existingTask});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.todo;
  String? _blockedBy;

  bool isLoading = false;
  final uuid = Uuid();

  static String? draftTitle;
  static String? draftDesc;

  @override
  void initState() {
    super.initState();

    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descController.text = widget.existingTask!.description;
      _dueDate = widget.existingTask!.dueDate;
      _status = widget.existingTask!.status;
      _blockedBy = widget.existingTask!.blockedBy;
    } else {
      if (draftTitle != null) _titleController.text = draftTitle!;
      if (draftDesc != null) _descController.text = draftDesc!;
    }
  }

  @override
  void dispose() {
    draftTitle = _titleController.text;
    draftDesc = _descController.text;
    super.dispose();
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _dueDate == null) return;

    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 2));

    final task = Task(
      id: widget.existingTask?.id ?? uuid.v4(),
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate!,
      status: _status,
      blockedBy: _blockedBy,
    );

    setState(() => isLoading = false);

    Navigator.pop(context, task);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null
            ? "Add Task"
            : "Edit Task"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(_dueDate == null
                      ? "Select Date"
                      : _dueDate.toString().split(" ")[0]),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text("Pick Date"),
                  )
                ],
              ),
              DropdownButton<TaskStatus>(
                value: _status,
                onChanged: (value) {
                  setState(() => _status = value!);
                },
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                hint: Text("Blocked By (optional)"),
                value: _blockedBy,
                onChanged: (value) {
                  setState(() => _blockedBy = value);
                },
                items: widget.tasks.map((task) {
                  return DropdownMenuItem(
                    value: task.id,
                    child: Text(task.title),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _saveTask,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}