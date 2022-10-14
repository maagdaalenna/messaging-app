import 'package:messaging_app/modules/shared/model/user.dart';

class Message {
  String body;
  User from;
  User? to;

  Message({
    required this.body,
    required this.from,
    this.to,
  });
}
