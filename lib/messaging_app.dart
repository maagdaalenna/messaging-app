import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/screens/login_screen.dart';
import 'package:messaging_app/modules/shared/themes/app_theme.dart';

class MessagingApp extends StatefulWidget {
  @override
  State<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LoginScreen(),
      theme: AppTheme.themeData,
    );
  }
}
