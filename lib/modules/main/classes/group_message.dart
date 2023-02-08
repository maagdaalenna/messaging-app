import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';

class GroupMessage {
  final String? id;
  String body;
  FirestoreUser from;
  DateTime datetime;

  GroupMessage({
    this.id,
    required this.body,
    required this.from,
    required this.datetime,
  });

  static GroupMessage fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json["id"],
      body: json["body"],
      from: json["from"],
      datetime: json["datetime"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "body": this.body,
      "from": this.from.id,
      "datetime": this.datetime,
    };
  }
}
