import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messaging_app/modules/auth/model/login_credentials.dart';
import 'package:messaging_app/modules/auth/model/register_credentials.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = GetIt.instance.get();
  bool loading = false;
  String? error = null;

  User? get user {
    return _auth.currentUser;
  }

  bool get authenticated {
    return _auth.currentUser == null ? false : true;
  }

  Future<void> register(RegisterCredentials credentials) async {
    error = null;
    loading = true;
    notifyListeners();

    if (credentials.password != credentials.confirmPassword) {
      error = "Passwords don't match!";
      loading = false;
      notifyListeners();
      return; // to stop execution
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );
      await _auth.signInWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );
      await _auth.currentUser!.updateDisplayName(credentials.displayName);
      loading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(LoginCredentials credentials) async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );
      loading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      loading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }
}
