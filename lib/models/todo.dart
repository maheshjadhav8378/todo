class Todo {
  int? id;
  String title;
  String description;
  DateTime? deadline;
  bool isComplete;

  Todo(
    this.id,
    this.title,
    this.description,
    this.deadline,
    this.isComplete,
  );

  @override
  String toString() {
    return '$id,$title,$description,${deadline?.toIso8601String()},$isComplete\n';
  }
}
