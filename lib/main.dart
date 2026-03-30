import 'dart:async';
import 'package:flutter/material.dart';
import 'models/task.dart';
import 'screens/add_task_screen.dart';

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskHomeScreen(),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  @override
  _TaskHomeScreenState createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<Task> tasks = [];

  String searchText = "";
  TaskStatus? selectedStatus;
  Timer? _debounce;

  bool _isBlocked(Task task) {
    if (task.blockedBy == null) return false;
    try {
      final blocker = tasks.firstWhere(
              (t) => t.id == task.blockedBy);

      return blocker.status != TaskStatus.done;
    } catch(e) {
      return false;
    }


  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = tasks.where((task) {
      final matchesSearch = searchText.isEmpty
          ? true
          : task.title.toLowerCase().contains(searchText.toLowerCase());

      final matchesStatus = selectedStatus == null
          ? true
          : task.status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Task Manager")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                _debounce = Timer(Duration(milliseconds: 300), () {
                  setState(() {
                    searchText = value;
                  });
                });
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<TaskStatus?>(
              value: selectedStatus,
              hint: Text("Filter by status"),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
              items: [
                DropdownMenuItem(value: null, child: Text("All")),
                ...TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
              ],
            ),
          ),

          Expanded(
            child: filteredTasks.isEmpty
                ? Center(child: Text("No Tasks Found"))
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];

                return GestureDetector(
                  onTap: () async {
                    final updatedTask = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(
                          tasks: tasks,
                          existingTask: task,
                        ),
                      ),
                    );

                    if (updatedTask != null) {
                      setState(() {
                        int i = tasks.indexWhere((t) => t.id == task.id);
                        tasks[i] = updatedTask;
                      });
                    }
                  },
                  child: Card(
                    color: _isBlocked(task) ? Colors.grey[300] : Colors.white, // ✅ FIX HERE
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _isBlocked(task)
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(task.description),
                                SizedBox(height: 5),
                                Text(
                                  "Due: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                task.status.name,
                                style: TextStyle(
                                  color: _getStatusColor(task.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    tasks.remove(task);
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(tasks: tasks),
            ),
          );

          if (newTask != null) {
            setState(() {
              tasks.add(newTask);
              searchText = "";        // reset search
              selectedStatus = null; // reset filter
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}