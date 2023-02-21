import 'dart:async';

import 'package:Fam.ly/modules/main/classes/enhanced_group.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GroupListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error = null;

  // 30 messages per page
  final int _pageSize = 30;

  bool lastGroupLoaded = false;

  List<EnhancedGroup> enhancedGroupList = [];

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  // it is called by the paging controllers when the user scrolls up to load
  // more messages
  Future<void> _fetchPage(
    String groupId,
    GroupMessage? pageKey,
    PagingController<GroupMessage?, MessageItem> pagingController,
  ) async {
    try {
      // request the next 30 messages from the group from firestore
      List<GroupMessage> newMessages = await getMessagesForGroup(
        groupId,
        pageKey,
        _pageSize,
      );

      // convert each GroupMessage to MessageItem
      List<MessageItem> newMessageItems = [];
      for (GroupMessage message in newMessages) {
        newMessageItems.add(
          MessageItem(
            isFromCurrentUser: currentUser.id == message.from.id,
            groupMessage: message,
          ),
        );
      }

      // if the number of received messages is less that 30 then there are no
      // messages left and this is the last page of messages
      bool isLastPage = newMessages.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newMessageItems);
      } else {
        // set the next page key to the last received message
        GroupMessage nextPageKey = newMessages.last;
        pagingController.appendPage(newMessageItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  // gets the json of the message from a document and enriches it with an "id"
  // and replaces the user id from the "from" key with the whole user after
  // getting it from firestore
  Future<Map<String, dynamic>> _getGroupMessageJsonFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    // get the json from the document
    var json = doc.data()!;
    // get the id of the document and put it in the json
    json["id"] = doc.id;
    // get the json of the user that sent the message from firestore
    var userJson = await _firestore
        .collection("users")
        .doc(json["from"])
        .get()
        .then((snapshot) {
      var userJson = snapshot.data();
      if (userJson != null) userJson["id"] = snapshot.id;
      return userJson;
    });
    json["from"] = userJson != null
        ? FirestoreUser.fromJson(userJson)
        : FirestoreUser.deletedAccount;

    return json;
  }

  // initialises a EnhancedGroup from a given Group
  EnhancedGroup _initEnhancedGroup(Group group) {
    bool isFirstCall = true;

    // sets the paging controller
    PagingController<GroupMessage?, MessageItem> pagingController =
        PagingController(firstPageKey: null);

    EnhancedGroup enhancedGroup = EnhancedGroup(
      group: group,
      pagingController: pagingController,
    );

    // sets the event subscription to listen to new messages in firestore
    StreamSubscription<QuerySnapshot> eventsSubscription = _firestore
        .collection("groups")
        .doc(group.id)
        .collection("messages")
        .snapshots()
        .listen((event) {
      // when the event subscription is created, our function is firstly called
      // as if everything is changed, so we want to skip over the first call
      if (isFirstCall) {
        isFirstCall = false;
        return;
      }

      // for each new message, insert it in the list
      event.docChanges.forEach((documentChange) async {
        if (pagingController.itemList != null) {
          var json = await _getGroupMessageJsonFromDoc(documentChange.doc);
          var message = GroupMessage.fromJson(json);
          pagingController.itemList!.insert(
            0,
            MessageItem(
              isFromCurrentUser: currentUser.id == message.from.id,
              groupMessage: message,
            ),
          );
          notifyListeners();
        }
      });
      _moveEnhancedGroupOnTop(enhancedGroup);
    });

    enhancedGroup.eventsSubscription = eventsSubscription;

    // give a function to be called when the users scrolls up to load more messages
    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(group.id!, pageKey, pagingController);
    });

    return enhancedGroup;
  }

  void _moveEnhancedGroupOnTop(EnhancedGroup enhancedGroup) {
    int? index = null;
    for (int i = 0; i < enhancedGroupList.length; i++) {
      if (enhancedGroupList[i].group.id == enhancedGroup.group.id) {
        index = i;
        break;
      }
    }
    if (index != null || index != 0) {
      enhancedGroupList.removeAt(index!);
      enhancedGroupList.insert(0, enhancedGroup);
    }
  }

  void _addToListInOrder(EnhancedGroup enhancedGroup) {
    if (enhancedGroupList.isEmpty) {
      enhancedGroupList.add(enhancedGroup);
      return;
    }
    for (int i = 0; i < enhancedGroupList.length; i++) {
      if (enhancedGroupList[i]
          .datetimeOfLastMessage
          .isBefore(enhancedGroup.datetimeOfLastMessage)) {
        enhancedGroupList.insert(i, enhancedGroup);
        return;
      }
    }
    enhancedGroupList.add(enhancedGroup);
  }

  Future<void> addGroup(Group group) async {
    String groupId = group.id!;

    EnhancedGroup enhancedGroup = _initEnhancedGroup(group);

    // loading the first page of messages for each group
    await _fetchPage(groupId, null, enhancedGroup.pagingController);

    _addToListInOrder(enhancedGroup);
    notifyListeners();
  }

  Future<void> removeGroup(Group group) async {
    String groupId = group.id!;
    for (int i = 0; i < enhancedGroupList.length; i++) {
      if (enhancedGroupList[i].group.id == groupId) {
        EnhancedGroup enhancedGroup = enhancedGroupList.removeAt(i);
        enhancedGroup.dispose();
        break;
      }
    }
    notifyListeners();
  }

  Future<void> loadGroupsForCurrentUser() async {
    String userId = _auth.currentUser!.uid;
    List<String> ids;

    ids = await _firestore
        .collection("users")
        .doc(userId)
        .collection("groups")
        .get()
        .then((snapshot) => [for (final doc in snapshot.docs) doc.id.trim()]);

    for (var groupId in ids) {
      var json = await _firestore
          .collection("groups")
          .doc(groupId)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        json["id"] = groupId;
        var group = Group.fromJson(json);

        EnhancedGroup enhancedGroup = _initEnhancedGroup(group);

        // Loading the first page of messages for each group
        await _fetchPage(groupId, null, enhancedGroup.pagingController);
        _addToListInOrder(enhancedGroup);
        notifyListeners();
      }
    }
    lastGroupLoaded = true;
    notifyListeners();
  }

  Future<List<GroupMessage>> getMessagesForGroup(
    String groupId,
    GroupMessage? lastMessage,
    int pageSize,
  ) async {
    // await new Future.delayed(const Duration(seconds: 2));
    List<Map<String, dynamic>> jsons;

    var query = _firestore
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("datetime", descending: true);
    if (lastMessage == null) {
      jsons = await query.limit(pageSize).get().then((snapshot) async {
        List<Map<String, dynamic>> jsons = [];
        for (final doc in snapshot.docs) {
          var json = await _getGroupMessageJsonFromDoc(doc);
          jsons.add(json);
        }
        return jsons;
      });
    } else {
      jsons = await query
          .startAfter([lastMessage.datetime])
          .limit(pageSize)
          .get()
          .then((snapshot) async {
            List<Map<String, dynamic>> jsons = [];
            for (final doc in snapshot.docs) {
              var json = await _getGroupMessageJsonFromDoc(doc);
              jsons.add(json);
            }
            return jsons;
          });
    }

    List<GroupMessage> messages = [];
    for (var json in jsons) {
      var message = GroupMessage.fromJson(json);
      messages.add(message);
    }

    return messages;
  }

  void disposeEverything() {
    for (EnhancedGroup enhancedGroup in enhancedGroupList) {
      enhancedGroup.dispose();
    }
    loading = false;
    error = null;
    lastGroupLoaded = false;
    enhancedGroupList = [];
  }
}
