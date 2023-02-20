import 'package:Fam.ly/modules/main/classes/group_provider_item.dart';
import 'package:Fam.ly/modules/main/screens/join_or_create_group_screen.dart';
import 'package:Fam.ly/modules/main/widgets/group_tile.dart';
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
      body: (_groupsProvider.groupProviderItemList.isEmpty &&
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
          : Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: _groupsProvider.groupProviderItemList.length,
                    itemBuilder: (BuildContext context, int index) {
                      GroupProviderItem groupProviderItem =
                          _groupsProvider.groupProviderItemList[index];
                      return GroupTile(
                        name: groupProviderItem.group.name,
                        fromAndBody: _groupsProvider
                                    .groupProviderItemList[index]
                                    .lastMessageItem ==
                                null
                            ? "No messages."
                            : _groupsProvider
                                .groupProviderItemList[index].lastMessageItem!
                                .showFromAndBody(),
                        onTap: () {
                          _groupsProvider.initialise(groupProviderItem);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                      );
                    }),
                if (!_groupsProvider.lastGroupLoaded)
                  Padding(
                    padding: EdgeInsets.all(themeSizes.spacingSmall),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
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
