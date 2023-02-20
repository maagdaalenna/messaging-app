import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String? error = null;

  Future<void> sendEmailVerification() async {
    if (_auth.currentUser == null) return;
    error = null;
    loading = true;
    notifyListeners();

    await _auth.currentUser!.sendEmailVerification();
    loading = false;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      List<String> userSignInMethods =
          await _auth.fetchSignInMethodsForEmail(email);
      if (userSignInMethods.length == 0) {
        error = "Email not found!";
      } else {
        await _auth.sendPasswordResetEmail(email: email);
      }
      loading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }
}
