import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/auth/providers/auth_navigation_provider.dart';
import 'package:Fam.ly/modules/auth/providers/auth_provider.dart';
import 'package:Fam.ly/modules/auth/providers/email_provider.dart';
import 'package:Fam.ly/modules/auth/screens/auth_screen.dart';
import 'package:Fam.ly/modules/auth/screens/confirm_account_screen.dart';
import 'package:Fam.ly/modules/main/providers/group_chat_provider.dart';
import 'package:Fam.ly/modules/main/providers/groups_provider.dart';
import 'package:Fam.ly/modules/main/screens/main_screen.dart';
import 'package:Fam.ly/modules/shared/themes/app_theme.dart';
import 'package:provider/provider.dart';

class MessagingApp extends StatefulWidget {
  @override
  State<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AuthNavigationProvider()),
        ChangeNotifierProvider(create: (context) => EmailProvider()),
        ChangeNotifierProvider(create: (context) => GroupsProvider()),
        ChangeNotifierProvider(create: (context) => GroupChatProvider()),
      ],
      child: MaterialApp(
        title: 'Fam.ly',
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.authenticated
                ? authProvider.confirmed!
                    ? MainScreen()
                    : ConfirmAccountScreen()
                : AuthScreen();
          },
        ),
        theme: AppTheme.themeData,
      ),
    );
  }
}
