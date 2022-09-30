import 'package:flutter/material.dart';
import 'package:messaging_app/modules/main/screens/family_chats_screen.dart';
import 'package:messaging_app/modules/main/screens/my_profile_screen.dart';
import 'package:messaging_app/modules/main/screens/private_chats_screen.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _selectedIndex = 1;

  final List<String> _titles = [
    "Private chats",
    "Family chats",
    "My profile",
  ];

  final List<IconData> _icons = [
    Icons.chat,
    Icons.family_restroom,
    Icons.person,
  ];

  final List<Widget> _pages = [
    PrivateChatsScreen(),
    FamilyChatsScreen(),
    MyProfileScreen(),
  ];

  void _onNavigationItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!; // is not null

    return Container(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: themeSizes.spacingLarge),
            child: Icon(_icons[_selectedIndex]),
          ),
          backgroundColor: theme.colorScheme.primary,
          title: Text(
            _titles[_selectedIndex],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _pages[_selectedIndex],
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
