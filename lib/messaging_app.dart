import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/providers/auth_navigation_provider.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/auth/screens/auth_screen.dart';
import 'package:messaging_app/modules/main/main_screen.dart';
import 'package:messaging_app/modules/shared/themes/app_theme.dart';
import 'package:provider/provider.dart';

class MessagingApp extends StatefulWidget {
  @override
  State<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fam.ly',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => AuthNavigationProvider()),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.authenticated ? MainScreen() : AuthScreen();
          },
        ),
      ),
      theme: AppTheme.themeData,
    );
  }
}
