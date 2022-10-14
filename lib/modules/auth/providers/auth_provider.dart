import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/model/login_credentials.dart';
import 'package:messaging_app/modules/auth/model/register_credentials.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String? error = null;

  User? get user {
    return _auth.currentUser;
  }

  bool get authenticated {
    return _auth.currentUser == null ? false : true;
  }

  bool? get confirmed {
    return authenticated ? user!.emailVerified : null;
  }

  Future<void> reload() async {
    if (loading == true) return;
    error = null;
    loading = true;
    notifyListeners();

    if (_auth.currentUser == null) {
      error = "No user is signed in!";
      loading = false;
      notifyListeners();
      return;
    }
    try {
      await _auth.currentUser!.reload();
      loading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterCredentials credentials) async {
    if (loading == true) return;
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
      await _auth.currentUser!.sendEmailVerification();
      loading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(LoginCredentials credentials) async {
    if (loading == true) return;
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
    if (loading == true) return;
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
