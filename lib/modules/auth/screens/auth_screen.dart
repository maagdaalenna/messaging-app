import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/auth/screens/login_screen.dart';
import 'package:messaging_app/modules/auth/screens/register_screen.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of(context);

    return _authProvider.activeAuthPage == ActiveAuthPage.login
        ? LoginScreen()
        : RegisterScreen();
  }
}
