import 'dart:convert';

import 'package:o/models/task.dart';

class Group {
  final String id;
  final String name;
  final String image;
  final List<Task> tasks;

  Group(
    this.id,
    this.name,
    this.image,
    this.tasks,
  );

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image, 'tasks': jsonEncode(tasks)};
  }

  factory Group.from(Map<String, dynamic> data) {
    return Group(
      data['id'],
      data['name'],
      data['image'],
      (data['tasks'] as List).map((e) => Task.from(e)).toList(),
    );
  }
}
