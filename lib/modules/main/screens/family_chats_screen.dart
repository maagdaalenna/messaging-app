import 'package:Fam.ly/modules/main/classes/group_provider_item.dart';
import 'package:Fam.ly/modules/main/screens/join_or_create_group_screen.dart';
import 'package:Fam.ly/modules/shared/widgets/placeholder_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/main/providers/groups_provider.dart';
import 'package:Fam.ly/modules/main/screens/chat_screen.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class FamilyChatsScreen extends StatefulWidget {
  const FamilyChatsScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatsScreen> createState() => _FamilyChatsScreenState();
}

class _FamilyChatsScreenState extends State<FamilyChatsScreen> {
  late GroupsProvider _groupsProvider;
  bool isFirstBuild = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupsProvider = Provider.of(context);

    if (isFirstBuild) {
      _groupsProvider.loadGroupsForCurrentUser();
      isFirstBuild = false;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: themeSizes.spacingLarge),
          child: Icon(Icons.family_restroom),
        ),
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          "Family chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: (_groupsProvider.groupList.isEmpty &&
              _groupsProvider.lastGroupLoaded)
          ? Padding(
              padding: EdgeInsets.all(themeSizes.spacingLarge),
              child: Center(
                child: Text(
                  "Press on the + button to get started by joining or creating a family group!",
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _groupsProvider.lastGroupLoaded
                  ? _groupsProvider.groupList.length
                  : _groupsProvider.groupList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (!_groupsProvider.lastGroupLoaded &&
                    index == _groupsProvider.groupList.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(themeSizes.spacingSmall),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  GroupProviderItem groupProviderItem =
                      _groupsProvider.groupList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.only(
                      left: themeSizes.spacingMedium,
                      right: themeSizes.spacingMedium,
                    ),
                    onTap: () {
                      _groupsProvider.initialise(groupProviderItem);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                    leading:
                        PlaceholderProfilePicture(size: themeSizes.iconLargest),
                    title: Text(
                      groupProviderItem.group.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      maxLines: 1,
                      _groupsProvider.groupList[index].lastMessageItem == null
                          ? "No messages."
                          : _groupsProvider.groupList[index].lastMessageItem!
                              .showFromAndBody(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  );
                }
              }),
      floatingActionButton: FloatingActionButton(
        heroTag: null, // solves the heroes error
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JoinOrCreateGroupScreen(),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(themeSizes.borderRadius),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _groupsProvider.disposeEverything();
    super.dispose();
  }
}
