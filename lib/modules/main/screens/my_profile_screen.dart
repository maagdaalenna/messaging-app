import 'package:flutter/material.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of(context);
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!; // is not null

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        child: _authProvider.loading
            ? CircularProgressIndicator()
            : Text("Log Out"),
        onPressed: () {
          _authProvider.logout();
        },
      ),
    );
  }
}
