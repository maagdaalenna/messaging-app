import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/providers/auth_navigation_provider.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/auth/providers/email_provider.dart';
import 'package:messaging_app/modules/auth/screens/auth_screen.dart';
import 'package:messaging_app/modules/auth/screens/confirm_account_screen.dart';
import 'package:messaging_app/modules/main/screens/main_screen.dart';
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
          ChangeNotifierProvider(create: (context) => EmailProvider()),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.authenticated
                ? authProvider.confirmed!
                    ? MainScreen()
                    : ConfirmAccountScreen()
                : AuthScreen();
          },
        ),
      ),
      theme: AppTheme.themeData,
    );
  }
}
