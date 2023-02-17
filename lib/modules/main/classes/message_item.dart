import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:intl/intl.dart';

class MessageItem {
  final GroupMessage groupMessage;
  final bool isFromCurrentUser;

  MessageItem({
    required this.groupMessage,
    required this.isFromCurrentUser,
  });

  String get from {
    return (isFromCurrentUser) ? "You" : groupMessage.from.displayName;
  }

  String get dateTimeString {
    return DateFormat.Hm().format(groupMessage.datetime) +
        ", " +
        DateFormat.yMMMd().format(groupMessage.datetime);
  }

  String showFromAndDate() {
    return from + ", " + dateTimeString;
  }

  String showFromAndBody() {
    return from + ": " + groupMessage.body;
  }
}
