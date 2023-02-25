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

class GroupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error = null;

  EnhancedGroup? _currentEnhancedGroup;

  FirestoreUser get currentUser {
    return FirestoreUser.fromUser(_auth.currentUser!);
  }

  EnhancedGroup? get currentEnhancedGroup {
    return _currentEnhancedGroup;
  }

  Group? get currentGroup {
    if (_currentEnhancedGroup == null) return null;
    return _currentEnhancedGroup!.group;
  }

  PagingController<GroupMessage?, MessageItem>? get currentPagingController {
    if (_currentEnhancedGroup == null) return null;
    return _currentEnhancedGroup!.pagingController;
  }

  // called when clicking on a group to set the current group
  void initialise(EnhancedGroup currentEnhancedGroup) {
    _currentEnhancedGroup = currentEnhancedGroup;
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

  Future<List<FirestoreUser>> getMembersForCurrentGroup(
    FirestoreUser? lastLoadedMember,
    int pageSize,
  ) async {
    List<String> ids;
    var query = _firestore
        .collection("groups")
        .doc(_currentEnhancedGroup!.group.id!)
        .collection("members")
        .orderBy(FieldPath.documentId);
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
}
