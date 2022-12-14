import 'package:flutter/material.dart';
import 'package:messaging_app/modules/main/providers/group_chat_provider.dart';
import 'package:messaging_app/modules/main/providers/groups_provider.dart';
import 'package:messaging_app/modules/main/screens/family_chats_screen.dart';
import 'package:messaging_app/modules/main/screens/my_profile_screen.dart';
import 'package:messaging_app/modules/main/screens/private_chats_screen.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _selectedIndex = 1;

  void _onNavigationItemTap(int index) {
    setState(() {
      // re-build the widget to display the new selected page
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes =
        theme.extension<ThemeSizesExtension>()!; // we surely know is not null

    return Container(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            PrivateChatsScreen(),
            FamilyChatsScreen(),
            MyProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.colorScheme.primary,
          selectedItemColor: theme.colorScheme.background,
          unselectedItemColor: theme.colorScheme.onPrimary,
          onTap: _onNavigationItemTap,
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              activeIcon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.chat),
              ),
              icon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.chat_outlined),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.family_restroom),
              ),
              icon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.family_restroom_outlined),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.person),
              ),
              icon: Padding(
                padding: EdgeInsets.only(top: themeSizes.spacingSmall),
                child: Icon(Icons.person_outlined),
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
