import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateMessage {
  final String? id;
  String body;
  FirestoreUser from;
  DateTime datetime;
  FirestoreUser to;

  PrivateMessage({
    this.id,
    required this.body,
    required this.from,
    required this.datetime,
    required this.to,
  });

  static PrivateMessage fromJson(Map<String, dynamic> json) {
    return PrivateMessage(
      id: json["id"],
      body: json["body"],
      from: json["from"],
      datetime: (json["datetime"] as Timestamp).toDate(),
      to: json["to"],
    );
  }
}
