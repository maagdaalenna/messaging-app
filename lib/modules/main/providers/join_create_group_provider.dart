import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinCreateGroupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error = null;
  Object? result = null;

  int? _currentGroupIndex;

  int? get currentGroupIndex {
    return _currentGroupIndex;
  }

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  Future<void> joinGroup(String gid) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      String uid = currentUser.id!;

      var json = await _firestore
          .collection("groups")
          .doc(gid)
          .get()
          .then((snapshot) => snapshot.data());

      if (json != null) {
        json["id"] = gid;
        result = Group.fromJson(json);

        var doc = await _firestore
            .collection("users")
            .doc(uid)
            .collection("groups")
            .doc(gid)
            .get();

        if (!doc.exists) {
          await _firestore
              .collection("users")
              .doc(uid)
              .collection("groups")
              .doc(gid)
              .set(Map<String, dynamic>());
          await _firestore
              .collection("groups")
              .doc(gid)
              .collection("members")
              .doc(uid)
              .set(Map<String, dynamic>());
        } else {
          error = "You are already in this Family Group!";
        }
      } else {
        error = "Family Group not found!";
      }

      loading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      error = "Unknown error.";
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(Group group) async {
    loading = true;
    error = null;
    result = null;
    notifyListeners();
    try {
      var doc = await _firestore.collection("groups").add(group.toJson());
      String gid = doc.id;
      String uid = currentUser.id!;
      await _firestore
          .collection("groups")
          .doc(gid)
          .collection("members")
          .doc(uid)
          .set(Map<String, dynamic>());
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("groups")
          .doc(gid)
          .set(Map<String, dynamic>());
      loading = false;
      result = gid;
      notifyListeners();
    } on FirebaseException catch (e) {
      error = "Unknown error.";
      loading = false;
      notifyListeners();
    }
  }
}
