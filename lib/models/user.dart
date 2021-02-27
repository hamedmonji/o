class User {
  final String name;
  final List<String> groupIds;
  final String imageUrl;

  User(this.name, this.groupIds, this.imageUrl);

  factory User.from(Map<String, dynamic> data) {
    return User(
        data['name'],
        (data['groups'] as List).map((e) => e.toString()).toList(),
        data['image_url']);
  }
}
