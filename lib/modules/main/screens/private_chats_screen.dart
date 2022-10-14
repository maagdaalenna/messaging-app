import 'package:flutter/material.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class PrivateChatsScreen extends StatefulWidget {
  const PrivateChatsScreen({Key? key}) : super(key: key);

  @override
  State<PrivateChatsScreen> createState() => _PrivateChatsScreenState();
}

class _PrivateChatsScreenState extends State<PrivateChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: themeSizes.spacingLarge),
          child: Icon(Icons.chat),
        ),
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          "Private chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(themeSizes.borderRadius),
          ),
        ),
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
