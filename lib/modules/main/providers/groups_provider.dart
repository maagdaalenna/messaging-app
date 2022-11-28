import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/modules/main/classes/group.dart';

class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Group>> getGroupsForCurrentUser(
    Group? lastGroup,
    int pageSize,
  ) async {
    // await new Future.delayed(const Duration(seconds: 2));
    String uid = _auth.currentUser!.uid;
    List<String> ids;
    var query = _firestore.collection("users").doc(uid).collection("groups");
    if (lastGroup == null) {
      ids = await query
          .limit(pageSize)
          .get()
          .then((snapshot) => [for (final doc in snapshot.docs) doc.id.trim()]);
    } else {
      ids = await query
          .startAfter([lastGroup.id])
          .limit(pageSize)
          .get()
          .then((snapshot) => [for (final doc in snapshot.docs) doc.id.trim()]);
    }
    List<Map<String, dynamic>> jsons = [];
    for (var id in ids) {
      var json = await _firestore
          .collection("groups")
          .doc(id)
          .get()
          .then((snapshot) => snapshot.data());
      if (json != null) {
        jsons.add(json);
      }
    }

    List<Group> groups = [];
    for (var json in jsons) {
      var group = Group.fromJson(json);
      groups.add(group);
    }

    return groups;
  }
}
