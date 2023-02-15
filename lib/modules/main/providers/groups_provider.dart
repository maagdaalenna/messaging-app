import 'dart:async';

import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error = null;

  int? _currentGroupIndex;

  int? get currentGroupIndex {
    return _currentGroupIndex;
  }

  // we need controllers for the infinite list view for messages of each group
  List<PagingController<GroupMessage?, MessageItem>> pagingControllerList = [];
  List<StreamSubscription<QuerySnapshot>> eventsSubscriptionList = [];
  List<Group> groups = [];
  List<bool> isFirstTimeBools = [];

  Group? get currentGroup {
    if (_currentGroupIndex == null) return null;
    return groups[_currentGroupIndex!];
  }

  PagingController<GroupMessage?, MessageItem>? get currentPagingController {
    if (_currentGroupIndex == null) return null;
    return pagingControllerList[_currentGroupIndex!];
  }

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  bool firstGroupLoaded = false;

  // 20 items per page
  static const _pageSize = 20;

  void initialise(int currentGroupIndex) {
    this._currentGroupIndex = currentGroupIndex;
  }

  Future<void> _fetchPage(
    String id,
    GroupMessage? pageKey,
    PagingController<GroupMessage?, MessageItem> pagingController,
  ) async {
    try {
      final newMessages = await getMessagesForGroup(
        id,
        pageKey,
        _pageSize,
      );

      List<MessageItem> newMessageItems = [];

      for (GroupMessage message in newMessages) {
        newMessageItems.add(MessageItem(
          onRight: currentUser.id == message.from.id,
          body: message.body,
          from: (currentUser.id == message.from.id)
              ? "You"
              : message.from.displayName,
          time: DateFormat.Hm().format(message.datetime) +
              ", " +
              DateFormat.yMMMd().format(message.datetime),
        ));
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

  Future<Map<String, dynamic>> _fromFirestoreToGroupMessage(
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
        : FirestoreUser(id: "", displayName: "Unknown", email: "");
    json["id"] = doc.id;

    return json;
  }

  Future<void> addGroup(Group group) async {
    String id = group.id!;
    groups.add(group);
    isFirstTimeBools.add(true);
    PagingController<GroupMessage?, MessageItem> pagingController =
        PagingController(firstPageKey: null);
    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(id, pageKey, pagingController);
    });
    StreamSubscription<QuerySnapshot> eventsSubscription = _firestore
        .collection("groups")
        .doc(id)
        .collection("messages")
        .snapshots()
        .listen((event) {
      int currentIndex = groups.indexOf(group);
      if (isFirstTimeBools[currentIndex]) {
        isFirstTimeBools[currentIndex] = false;
        return;
      }
      // print("something changed!!!!!!!!!!!!!!!!!");
      event.docChanges.forEach((element) async {
        if (pagingController.itemList != null) {
          var json = await _fromFirestoreToGroupMessage(element.doc);
          var message = GroupMessage.fromJson(json);
          pagingController.itemList!.insert(
              0,
              MessageItem(
                onRight: currentUser.id == message.from.id,
                body: message.body,
                from: (currentUser.id == message.from.id)
                    ? "You"
                    : message.from.displayName,
                time: DateFormat.Hm().format(message.datetime) +
                    ", " +
                    DateFormat.yMMMd().format(message.datetime),
              ));
          notifyListeners();
        }
      });
    });

    // Loading the first page of messages for each group
    await _fetchPage(id, null, pagingController);

    pagingControllerList.add(pagingController);
    eventsSubscriptionList.add(eventsSubscription);
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

    for (var id in ids) {
      var json = await _firestore
          .collection("groups")
          .doc(id)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        isFirstTimeBools.add(true);
        json["id"] = id;
        var group = Group.fromJson(json);
        PagingController<GroupMessage?, MessageItem> pagingController =
            PagingController(firstPageKey: null);
        pagingController.addPageRequestListener((pageKey) async {
          await _fetchPage(id, pageKey, pagingController);
        });
        StreamSubscription<QuerySnapshot> eventsSubscription = _firestore
            .collection("groups")
            .doc(id)
            .collection("messages")
            .snapshots()
            .listen((event) {
          int currentIndex = ids.indexOf(id);
          if (isFirstTimeBools[currentIndex]) {
            isFirstTimeBools[currentIndex] = false;
            return;
          }
          // print("something changed!!!!!!!!!!!!!!!!!");
          event.docChanges.forEach((element) async {
            if (pagingController.itemList != null) {
              var json = await _fromFirestoreToGroupMessage(element.doc);
              var message = GroupMessage.fromJson(json);
              pagingController.itemList!.insert(
                  0,
                  MessageItem(
                    onRight: currentUser.id == message.from.id,
                    body: message.body,
                    from: (currentUser.id == message.from.id)
                        ? "You"
                        : message.from.displayName,
                    time: DateFormat.Hm().format(message.datetime) +
                        ", " +
                        DateFormat.yMMMd().format(message.datetime),
                  ));
              notifyListeners();
            }
          });
        });

        // Loading the first page of messages for each group
        await _fetchPage(id, null, pagingController);

        groups.add(group);
        pagingControllerList.add(pagingController);
        eventsSubscriptionList.add(eventsSubscription);
        firstGroupLoaded = true;
        notifyListeners();
      }
    }
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
          var json = await _fromFirestoreToGroupMessage(doc);
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
              var json = await _fromFirestoreToGroupMessage(doc);
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
    for (var eventsSubscription in eventsSubscriptionList) {
      eventsSubscription.cancel();
    }
    for (var pagingController in pagingControllerList) {
      pagingController.dispose();
    }
  }
}
