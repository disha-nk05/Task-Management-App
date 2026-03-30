enum TaskStatus { todo, inProgress, done }

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TaskStatus status;
  String? blockedBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });
}