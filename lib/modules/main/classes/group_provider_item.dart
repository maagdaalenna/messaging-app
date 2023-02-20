import 'dart:async';

import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GroupProviderItem {
  final Group group;
  final PagingController<GroupMessage?, MessageItem> pagingController;
  StreamSubscription<QuerySnapshot>? eventsSubscription;

  GroupProviderItem({
    required this.group,
    required this.pagingController,
    this.eventsSubscription,
  });

  List<MessageItem> get messages {
    if (pagingController.itemList != null)
      return pagingController.itemList!;
    else
      return [];
  }

  MessageItem? get lastMessageItem {
    if (messages.isEmpty) {
      return null;
    } else {
      return messages[0];
    }
  }

  DateTime get datetimeOfLastMessage {
    if (messages.isEmpty) {
      return group.created;
    } else {
      return messages[0].groupMessage.datetime;
    }
  }

  void dispose() {
    pagingController.dispose();
    if (eventsSubscription != null) {
      eventsSubscription!.cancel();
    }
  }
}
