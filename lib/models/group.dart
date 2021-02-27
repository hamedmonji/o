class Group {
  final String name;
  final String image;

  Group(this.name, this.image);

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }
}
