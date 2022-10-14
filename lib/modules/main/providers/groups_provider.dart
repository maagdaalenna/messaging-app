import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool loading = false;
  String? error = null;

  Future<void> fetchGroups() async {
    var groups = await _firestore.collection("groups").get();
  }
}
