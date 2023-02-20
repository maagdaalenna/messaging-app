import 'dart:async';

import 'package:Fam.ly/modules/main/classes/group_provider_item.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error = null;

  GroupProviderItem? _currentGroupProviderItem;

  // 30 messages per page
  final _pageSize = 30;

  bool lastGroupLoaded = false;

  List<GroupProviderItem> groupProviderItemList = [];

  GroupProviderItem? get currentGroupProviderItem {
    return _currentGroupProviderItem;
  }

  Group? get currentGroup {
    if (_currentGroupProviderItem == null) return null;
    return _currentGroupProviderItem!.group;
  }

  PagingController<GroupMessage?, MessageItem>? get currentPagingController {
    if (_currentGroupProviderItem == null) return null;
    return _currentGroupProviderItem!.pagingController;
  }

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  // called when clicking on a group to set the current group
  void initialise(GroupProviderItem currentGroupProviderItem) {
    _currentGroupProviderItem = currentGroupProviderItem;
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
        : FirestoreUser(id: "", displayName: "Deleted Account", email: "");

    return json;
  }

  // initialises a GroupProviderItem from a given Group
  GroupProviderItem _initGroupProviderItem(Group group) {
    bool isFirstCall = true;

    // sets the paging controller
    PagingController<GroupMessage?, MessageItem> pagingController =
        PagingController(firstPageKey: null);

    GroupProviderItem groupProviderItem = GroupProviderItem(
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
      _moveGroupProviderItemOnTop(groupProviderItem);
    });

    groupProviderItem.eventsSubscription = eventsSubscription;

    // give a function to be called when the users scrolls up to load more messages
    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(group.id!, pageKey, pagingController);
    });

    return groupProviderItem;
  }

  void _moveGroupProviderItemOnTop(GroupProviderItem groupProviderItem) {
    int? index = null;
    for (int i = 0; i < groupProviderItemList.length; i++) {
      if (groupProviderItemList[i].group.id == groupProviderItem.group.id) {
        index = i;
        break;
      }
    }
    if (index != null || index != 0) {
      groupProviderItemList.removeAt(index!);
      groupProviderItemList.insert(0, groupProviderItem);
    }
  }

  void _addToListInOrder(GroupProviderItem groupProviderItem) {
    if (groupProviderItemList.isEmpty) {
      groupProviderItemList.add(groupProviderItem);
      return;
    }
    for (int i = 0; i < groupProviderItemList.length; i++) {
      if (groupProviderItemList[i]
          .datetimeOfLastMessage
          .isBefore(groupProviderItem.datetimeOfLastMessage)) {
        groupProviderItemList.insert(i, groupProviderItem);
        return;
      }
    }
    groupProviderItemList.add(groupProviderItem);
  }

  Future<void> addGroup(Group group) async {
    String groupId = group.id!;

    GroupProviderItem groupProviderItem = _initGroupProviderItem(group);

    // loading the first page of messages for each group
    await _fetchPage(groupId, null, groupProviderItem.pagingController);

    _addToListInOrder(groupProviderItem);
    notifyListeners();
  }

  Future<void> removeGroup(Group group) async {
    String groupId = group.id!;
    for (int i = 0; i < groupProviderItemList.length; i++) {
      if (groupProviderItemList[i].group.id == groupId) {
        var groupProviderItem = groupProviderItemList.removeAt(i);
        groupProviderItem.dispose();
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

        GroupProviderItem groupProviderItem = _initGroupProviderItem(group);

        // Loading the first page of messages for each group
        await _fetchPage(groupId, null, groupProviderItem.pagingController);
        _addToListInOrder(groupProviderItem);
        notifyListeners();
      }
    }
    lastGroupLoaded = true;
    notifyListeners();
  }

  Future<List<FirestoreUser>> getMembersForCurrentGroup(
    FirestoreUser? lastLoadedMember,
    int pageSize,
  ) async {
    List<String> ids;
    var query = _firestore
        .collection("groups")
        .doc(_currentGroupProviderItem!.group.id!)
        .collection("members");
    if (lastLoadedMember == null) {
      ids = await query.limit(pageSize).get().then((snapshot) async {
        List<String> ids = [];
        for (final doc in snapshot.docs) {
          ids.add(doc.id);
        }
        return ids;
      });
    } else {
      ids = await query
          .startAfter([lastLoadedMember.id])
          .limit(pageSize)
          .get()
          .then((snapshot) async {
            List<String> ids = [];
            for (final doc in snapshot.docs) {
              ids.add(doc.id);
            }
            return ids;
          });
    }

    List<FirestoreUser> newlyLoadedMembers = [];
    for (var userId in ids) {
      var json = await _firestore
          .collection("users")
          .doc(userId)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        json["id"] = userId;
        var member = FirestoreUser.fromJson(json);
        newlyLoadedMembers.add(member);
      }
    }
    return newlyLoadedMembers;
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

  Future<void> addMessageForCurrentGroup(
    GroupMessage groupMessage,
  ) async {
    String groupId = currentGroup!.id!;
    if (loading == true) return;
    error = null;
    loading = true;
    notifyListeners();

    try {
      await _firestore
          .collection("groups")
          .doc(groupId)
          .collection("messages")
          .add(groupMessage.toJson());
      loading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }

  void disposeEverything() {
    for (var groupProviderItem in groupProviderItemList) {
      groupProviderItem.dispose();
    }
    loading = false;
    error = null;
    _currentGroupProviderItem = null;
    lastGroupLoaded = false;
    groupProviderItemList = [];
  }
}
