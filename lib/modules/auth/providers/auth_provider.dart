import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/auth/classes/login_credentials.dart';
import 'package:Fam.ly/modules/auth/classes/register_credentials.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      FirestoreUser userToUpload = FirestoreUser(
        id: _auth.currentUser!.uid,
        displayName: _auth.currentUser!.displayName!,
        email: _auth.currentUser!.email!,
      );
      await _firestore
          .collection("users")
          .doc(userToUpload.id)
          .set(userToUpload.toJson()); // upload to firestore
      await _auth.currentUser!.sendEmailVerification();
      loading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
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
    } on FirebaseException catch (e) {
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
    } on FirebaseException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
    }
  }
}
