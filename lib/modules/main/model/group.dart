import 'package:messaging_app/modules/main/model/message.dart';
import 'package:messaging_app/modules/shared/model/user.dart';

class Group {
  final String name;
  final List<User> members;
  final List<Message> messages;

  Group({
    required this.name,
    required this.members,
    required this.messages,
  });

  // Group.fromJson(Map<String, dynamic> json) {
  //   return Group(name: json["name"], );
  // }
}



// {
//   "name": "Family 1",
//   "members": {
//     "member1": {
//       "displayName": "Magda",
//     }
//   },
//   "nr": 1,
// }
