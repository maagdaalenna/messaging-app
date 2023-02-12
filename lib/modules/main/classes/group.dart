class Group {
  final String? id;
  final String name;
  // final Image profilePicture

  Group({
    this.id,
    required this.name,
  });

  static Group fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
    );
  }
}
