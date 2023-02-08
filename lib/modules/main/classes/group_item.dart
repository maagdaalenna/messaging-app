import 'package:Fam.ly/modules/main/classes/group.dart';

class GroupItem {
  final Group group;
  final String lastFrom;
  final String lastMessage;
  // final Image profilePicture

  GroupItem({
    required this.group,
    required this.lastFrom,
    required this.lastMessage,
  });

  String showUserAndMessage() {
    return lastFrom + ": " + lastMessage;
  }
}
