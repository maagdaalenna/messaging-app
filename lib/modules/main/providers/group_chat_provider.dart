import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';

class GroupChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 20 items per page
  static const _pageSize = 15;

  // we need a controller for the infinite list view
  final PagingController<GroupMessage?, MessageItem> _pagingController =
      PagingController(firstPageKey: null);

  bool loading = false;
  String? error = null;
  Group? _currentGroup;

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  Group? get currentGroup {
    return _currentGroup;
  }

  PagingController<GroupMessage?, MessageItem> get pagingController {
    return _pagingController;
  }

  Future<void> _fetchPage(GroupMessage? pageKey) async {
    try {
      final newMessages = await getMessagesForCurrentGroup(
        pageKey,
        _pageSize,
      );

      List<MessageItem> newMessageItems = [];

      for (GroupMessage message in newMessages) {
        newMessageItems.add(MessageItem(
          body: message.body,
          from: (currentUser.id != message.from.id)
              ? message.from.displayName
              : "You",
          time: message.datetime.hour.toString() +
              ":" +
              message.datetime.minute.toString(),
        ));
      }
      final isLastPage = newMessages.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newMessageItems);
      } else {
        final nextPageKey = newMessages.last;
        _pagingController.appendPage(newMessageItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void initialise(Group currentGroup) {
    this._currentGroup = currentGroup;
    String gid = _currentGroup!.id!;
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _firestore
        .collection("groups")
        .doc(gid)
        .collection("messages")
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {});
    });
  }

  Future<List<GroupMessage>> getMessagesForCurrentGroup(
    GroupMessage? lastMessage,
    int pageSize,
  ) async {
    // await new Future.delayed(const Duration(seconds: 2));
    String gid = _currentGroup!.id!;
    List<Map<String, dynamic>> jsons;

    var query = _firestore
        .collection("groups")
        .doc(gid)
        .collection("messages")
        .orderBy("datetime", descending: true);
    if (lastMessage == null) {
      jsons = await query.limit(pageSize).get().then((snapshot) async {
        List<Map<String, dynamic>> jsons = [];
        for (final doc in snapshot.docs) {
          var json = doc.data();

          var userJson = await _firestore
              .collection("users")
              .doc(json["from"])
              .get()
              .then((snapshot) {
            var userJson = snapshot.data();
            if (userJson != null) userJson["id"] = snapshot.id;
            return userJson;
          });

          json["datetime"] = DateTime.parse(
              (json["datetime"] as Timestamp).toDate().toString());
          json["from"] = userJson != null
              ? FirestoreUser.fromJson(userJson)
              : FirestoreUser(id: "", displayName: "Unknown", email: "");
          json["id"] = doc.id;
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
              var json = doc.data();

              var userJson = await _firestore
                  .collection("users")
                  .doc(json["from"])
                  .get()
                  .then((snapshot) {
                var userJson = snapshot.data();
                if (userJson != null) userJson["id"] = snapshot.id;
                return userJson;
              });

              json["datetime"] = DateTime.parse(
                  (json["datetime"] as Timestamp).toDate().toString());
              json["from"] = userJson != null
                  ? FirestoreUser.fromJson(userJson)
                  : FirestoreUser(id: "", displayName: "Unknown", email: "");
              json["id"] = doc.id;
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
    String gid = _currentGroup!.id!;
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
}
