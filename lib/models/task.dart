enum TaskState { UnAssigned, InProgress, Done }

class Task {
  final String id;
  final String name;
  final String assigneId;
  final TaskState state;

  Task(this.id, this.name, this.assigneId, this.state);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assigneId': assigneId,
      'state': state.index
    };
  }

  factory Task.from(Map<String, dynamic> data) {
    return Task(data['id'], data['name'], data['assigneId'],
        TaskState.values[data['state']]);
  }
}
