import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String? error = null;

  Future<void> sendEmailVerification() async {
    if (loading == true) return;
    if (_auth.currentUser == null) return;
    error = null;
    loading = true;
    notifyListeners();

    await _auth.currentUser!.sendEmailVerification();
    loading = false;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (loading == true) return;
    error = null;
    loading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      loading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }
}
