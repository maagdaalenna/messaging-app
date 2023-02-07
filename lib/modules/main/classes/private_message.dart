import 'package:messaging_app/modules/shared/classes/firestore_user.dart';

class Message {
  final String? id;
  String body;
  FirestoreUser from;
  DateTime datetime;
  FirestoreUser to;

  Message({
    this.id,
    required this.body,
    required this.from,
    required this.datetime,
    required this.to,
  });

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      body: json["body"],
      from: json["from"],
      datetime: json["datetime"],
      to: json["to"],
    );
  }
}
