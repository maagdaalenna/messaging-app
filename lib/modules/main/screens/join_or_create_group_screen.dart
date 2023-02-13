import 'package:Fam.ly/modules/main/screens/create_group_screen.dart';
import 'package:Fam.ly/modules/main/screens/join_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';

class JoinOrCreateGroupScreen extends StatefulWidget {
  const JoinOrCreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<JoinOrCreateGroupScreen> createState() =>
      _JoinOrCreateGroupScreenState();
}

class _JoinOrCreateGroupScreenState extends State<JoinOrCreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: theme.colorScheme.primary,
              tabs: [
                Padding(
                  padding: EdgeInsets.all(themeSizes.spacingSmaller),
                  child: Text("Join"),
                ),
                Padding(
                  padding: EdgeInsets.all(themeSizes.spacingSmaller),
                  child: Text("Create"),
                ),
              ],
            ),
            title: const Text("Join or create a family group"),
          ),
          body: TabBarView(
            children: [
              JoinGroupScreen(),
              CreateGroupScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
