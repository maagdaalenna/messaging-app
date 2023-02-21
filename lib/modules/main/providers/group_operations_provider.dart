import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupOperationsProvider extends ChangeNotifier {
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

  Future<void> joinGroup(String groupId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      String userId = currentUser.id!;

      // get the json of the group from firestore with the given id
      var json = await _firestore
          .collection("groups")
          .doc(groupId)
          .get()
          .then((snapshot) => snapshot.data());

      // check if the group exists
      if (json != null) {
        json["id"] = groupId;
        result = Group.fromJson(json);

        // check if the group already exists in the user's group list
        var doc = await _firestore
            .collection("users")
            .doc(userId)
            .collection("groups")
            .doc(groupId)
            .get();

        if (!doc.exists) {
          // add the group id to the user's group list
          await _firestore
              .collection("users")
              .doc(userId)
              .collection("groups")
              .doc(groupId)
              .set(Map<String, dynamic>());
          // add the user id to the group's member list
          await _firestore
              .collection("groups")
              .doc(groupId)
              .collection("members")
              .doc(userId)
              .set(Map<String, dynamic>());
        } else {
          error = "You are already in this Family Group!";
        }
      } else {
        error = "Family Group not found!";
      }

      loading = false;
      notifyListeners();
    } on FirebaseException catch (_) {
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
      // add the new group to firestore
      var doc = await _firestore.collection("groups").add(group.toJson());
      String groupId = doc.id;
      String userId = currentUser.id!;
      // add the group id to the user's group list
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("groups")
          .doc(groupId)
          .set(Map<String, dynamic>());
      // add the user id to the group's member list
      await _firestore
          .collection("groups")
          .doc(groupId)
          .collection("members")
          .doc(userId)
          .set(Map<String, dynamic>());
      loading = false;
      result = groupId;
      notifyListeners();
    } on FirebaseException catch (_) {
      error = "Unknown error.";
      loading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGroup(String groupId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      String userId = currentUser.id!;

      // remove the group id from the user's group list
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("groups")
          .doc(groupId)
          .delete();
      // remove the user id from the group's member list
      await _firestore
          .collection("groups")
          .doc(groupId)
          .collection("members")
          .doc(userId)
          .delete();

      loading = false;
      notifyListeners();
    } on FirebaseException catch (_) {
      error = "Unknown error.";
      loading = false;
      notifyListeners();
    }
  }
}
