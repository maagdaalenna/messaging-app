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

  // 30 items per page
  final _pageSize = 30;

  bool lastGroupLoaded = false;

  List<GroupProviderItem> groupList = [];

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

  void initialise(GroupProviderItem currentGroupProviderItem) {
    this._currentGroupProviderItem = currentGroupProviderItem;
  }

  Future<void> _fetchPage(
    String gid,
    GroupMessage? pageKey,
    PagingController<GroupMessage?, MessageItem> pagingController,
  ) async {
    try {
      final newMessages = await getMessagesForGroup(
        gid,
        pageKey,
        _pageSize,
      );

      List<MessageItem> newMessageItems = [];

      for (GroupMessage message in newMessages) {
        newMessageItems.add(
          MessageItem(
            isFromCurrentUser: currentUser.id == message.from.id,
            groupMessage: message,
          ),
        );
      }
      final isLastPage = newMessages.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newMessageItems);
      } else {
        final nextPageKey = newMessages.last;
        pagingController.appendPage(newMessageItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  Future<Map<String, dynamic>> _getGroupMessageJsonFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    var json = doc.data()!;
    var userJson = await _firestore
        .collection("users")
        .doc(json["from"])
        .get()
        .then((snapshot) {
      var userJson = snapshot.data();
      if (userJson != null) userJson["id"] = snapshot.id;
      return userJson;
    });

    json["datetime"] =
        DateTime.parse((json["datetime"] as Timestamp).toDate().toString());
    json["from"] = userJson != null
        ? FirestoreUser.fromJson(userJson)
        : FirestoreUser(id: "", displayName: "Deleted Account", email: "");
    json["id"] = doc.id;

    return json;
  }

  GroupProviderItem _initGroupProviderItem(Group group) {
    bool isFirstTimeBool = true;

    PagingController<GroupMessage?, MessageItem> pagingController =
        PagingController(firstPageKey: null);

    GroupProviderItem groupProviderItem = GroupProviderItem(
      group: group,
      pagingController: pagingController,
      isFirstTimeBool: true,
    );

    StreamSubscription<QuerySnapshot> eventsSubscription = _firestore
        .collection("groups")
        .doc(group.id)
        .collection("messages")
        .snapshots()
        .listen((event) {
      if (isFirstTimeBool) {
        isFirstTimeBool = false;
        return;
      }
      // print("something changed!!!!!!!!!!!!!!!!!");
      event.docChanges.forEach((element) async {
        if (pagingController.itemList != null) {
          var json = await _getGroupMessageJsonFromDoc(element.doc);
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
      _moveElementOnTop(groupProviderItem);
    });

    groupProviderItem.eventsSubscription = eventsSubscription;

    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(group.id!, pageKey, pagingController);
    });

    return groupProviderItem;
  }

  void _moveElementOnTop(GroupProviderItem groupProviderItem) {
    int? index = null;
    for (int i = 0; i < groupList.length; i++) {
      if (groupList[i].group.id == groupProviderItem.group.id) {
        index = i;
        break;
      }
    }
    if (index != null || index != 0) {
      groupList.removeAt(index!);
      groupList.insert(0, groupProviderItem);
    }
  }

  void _addToListInOrder(GroupProviderItem groupProviderItem) {
    if (groupList.isEmpty) {
      groupList.add(groupProviderItem);
      return;
    }
    for (int i = 0; i < groupList.length; i++) {
      if (groupList[i]
          .datetimeOfLastMessage
          .isBefore(groupProviderItem.datetimeOfLastMessage)) {
        groupList.insert(i, groupProviderItem);
        return;
      }
    }
    groupList.add(groupProviderItem);
  }

  Future<void> addGroup(Group group) async {
    String gid = group.id!;

    GroupProviderItem groupProviderItem = _initGroupProviderItem(group);

    // Loading the first page of messages for each group
    await _fetchPage(gid, null, groupProviderItem.pagingController);

    _addToListInOrder(groupProviderItem);
    notifyListeners();
  }

  Future<void> removeGroup(Group group) async {
    String gid = group.id!;
    for (int i = 0; i < groupList.length; i++) {
      if (groupList[i].group.id == gid) {
        groupList.removeAt(i);
        break;
      }
    }
    notifyListeners();
  }

  Future<void> loadGroupsForCurrentUser() async {
    String uid = _auth.currentUser!.uid;
    List<String> ids;

    ids = await _firestore
        .collection("users")
        .doc(uid)
        .collection("groups")
        .get()
        .then((snapshot) => [for (final doc in snapshot.docs) doc.id.trim()]);

    for (var gid in ids) {
      var json = await _firestore
          .collection("groups")
          .doc(gid)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        json["id"] = gid;
        var group = Group.fromJson(json);

        GroupProviderItem groupProviderItem = _initGroupProviderItem(group);

        // Loading the first page of messages for each group
        await _fetchPage(gid, null, groupProviderItem.pagingController);
        _addToListInOrder(groupProviderItem);
        notifyListeners();
      }
    }
    lastGroupLoaded = true;
    notifyListeners();
  }

  Future<List<FirestoreUser>> getMembersForCurrentGroup(
    FirestoreUser? lastMember,
    int pageSize,
  ) async {
    List<String> ids;
    var query = _firestore
        .collection("groups")
        .doc(_currentGroupProviderItem!.group.id!)
        .collection("members");
    if (lastMember == null) {
      ids = await query.limit(pageSize).get().then((snapshot) async {
        List<String> ids = [];
        for (final doc in snapshot.docs) {
          ids.add(doc.id);
        }
        return ids;
      });
    } else {
      ids = await query
          .startAfter([lastMember.id])
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

    List<FirestoreUser> newMembers = [];
    for (var uid in ids) {
      var json = await _firestore
          .collection("users")
          .doc(uid)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        json["id"] = uid;
        var member = FirestoreUser.fromJson(json);
        newMembers.add(member);
      }
    }
    return newMembers;
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
    String gid = currentGroup!.id!;
    if (loading == true) return;
    error = null;
    loading = true;
    notifyListeners();

    try {
      await _firestore
          .collection("groups")
          .doc(gid)
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
    for (var groupProviderItem in groupList) {
      groupProviderItem.dispose();
    }
    loading = false;
    error = null;
    _currentGroupProviderItem = null;
    lastGroupLoaded = false;
    groupList = [];
  }
}
