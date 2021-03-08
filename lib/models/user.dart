class User {
  final String id;
  final String name;
  final List<String> groupIds;
  final String imageUrl;

  User(this.id, this.name, this.groupIds, this.imageUrl);

  factory User.from(Map<String, dynamic> data) {
    return User(
        data['id'],
        data['name'],
        (data['groups'] as List).map((e) => e.toString()).toList(),
        data['image_url']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'groups': groupIds, 'image_url': imageUrl};
  }
}
