import 'package:messaging_app/modules/main/classes/group.dart';

class GroupItem {
  final Group group;
  final String from;
  final String lastMessage;
  // final Image profilePicture

  GroupItem({
    required this.group,
    required this.from,
    required this.lastMessage,
  });

  String showUserAndMessage() {
    return from + ": " + lastMessage;
  }
}
