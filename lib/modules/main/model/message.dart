import 'package:messaging_app/modules/shared/model/firestore_user.dart';

class Message {
  String body;
  FirestoreUser from;
  FirestoreUser? to;

  Message({
    required this.body,
    required this.from,
    this.to,
  });
}
