import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String? id;
  final String name;
  final DateTime created;
  // final Image profilePicture

  Group({
    this.id,
    required this.name,
    required this.created,
  });

  static Group fromJson(Map<String, dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
      created: (json["created"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "created": this.created,
    };
  }
}
