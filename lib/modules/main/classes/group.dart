class Group {
  String? id;
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

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is Group && other.runtimeType == runtimeType && other.id == id;
  }
}
