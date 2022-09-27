import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = GetIt.I.get();
  ActiveAuthPage activeAuthPage = ActiveAuthPage.login;

  void setLoginPageActive() {
    activeAuthPage = ActiveAuthPage.login;
    notifyListeners();
  }

  void setRegisterPageActive() {
    activeAuthPage = ActiveAuthPage.register;
    notifyListeners();
  }
}

enum ActiveAuthPage {
  login,
  register,
}
