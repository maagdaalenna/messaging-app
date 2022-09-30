import 'package:flutter/material.dart';

class AuthNavigationProvider extends ChangeNotifier {
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
