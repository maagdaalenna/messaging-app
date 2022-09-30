import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/auth/screens/auth_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of(context);

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_authProvider.user!.displayName!),
        ),
        body: ElevatedButton(
          child: _authProvider.loading
              ? CircularProgressIndicator()
              : Text("logout"),
          onPressed: () {
            _authProvider.logout();
          },
        ),
      ),
    );
  }
}
