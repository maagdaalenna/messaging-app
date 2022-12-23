import 'package:messaging_app/modules/shared/classes/firestore_user.dart';

class Message {
  String body;
  FirestoreUser from;
  DateTime datetime;
  FirestoreUser? to;

  Message({
    required this.body,
    required this.from,
    required this.datetime,
    this.to,
  });

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      body: json["body"],
      from: json["from"],
      datetime: json["datetime"],
      to: json["to"],
    );
  }
}
