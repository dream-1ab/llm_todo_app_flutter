class Todo {
  final String id;
  final String title;
  final String? details;
  final DateTime createdAt;
  final DateTime? dueDate;
  bool isCompleted;

  Todo({
    required this.title,
    this.details,
    this.dueDate,
    this.isCompleted = false,
  })  : id = DateTime.now().toString(),
        createdAt = DateTime.now();
}