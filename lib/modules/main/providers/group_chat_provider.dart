import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/modules/main/classes/group.dart';
import 'package:messaging_app/modules/main/classes/message.dart';
import 'package:messaging_app/modules/shared/classes/firestore_user.dart';

class GroupChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // bool loading = false;
  // String? error = null;
  Group? currentGroup;
  var currentUser = FirebaseAuth.instance.currentUser!;

  Future<List<Message>> getMessagesForCurrentGroup(
    Message? lastMessage,
    int pageSize,
  ) async {
    // await new Future.delayed(const Duration(seconds: 2));
    String gid = currentGroup!.id!;
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
          .startAfter([lastMessage.id])
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

    List<Message> messages = [];
    for (var json in jsons) {
      var message = Message.fromJson(json);
      messages.add(message);
    }

    return messages;
  }
}
