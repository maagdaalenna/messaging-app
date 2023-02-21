import 'package:Fam.ly/modules/main/classes/enhanced_group.dart';
import 'package:Fam.ly/modules/main/providers/group_provider.dart';
import 'package:Fam.ly/modules/main/screens/join_or_create_group_screen.dart';
import 'package:Fam.ly/modules/main/widgets/group_tile.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/main/providers/group_list_provider.dart';
import 'package:Fam.ly/modules/main/screens/chat_screen.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class FamilyChatsScreen extends StatefulWidget {
  const FamilyChatsScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatsScreen> createState() => _FamilyChatsScreenState();
}

class _FamilyChatsScreenState extends State<FamilyChatsScreen> {
  late GroupListProvider _groupListProvider;
  late GroupProvider _groupProvider;
  bool isFirstBuild = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupListProvider = Provider.of(context);
    _groupProvider = Provider.of(context);

    if (isFirstBuild) {
      _groupListProvider.loadGroupsForCurrentUser();
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
      body: (_groupListProvider.enhancedGroupList.isEmpty &&
              _groupListProvider.lastGroupLoaded)
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
                    itemCount: _groupListProvider.enhancedGroupList.length,
                    itemBuilder: (BuildContext context, int index) {
                      EnhancedGroup groupProviderItem =
                          _groupListProvider.enhancedGroupList[index];
                      return GroupTile(
                        name: groupProviderItem.group.name,
                        fromAndBody: _groupListProvider
                                    .enhancedGroupList[index].lastMessageItem ==
                                null
                            ? "No messages."
                            : _groupListProvider
                                .enhancedGroupList[index].lastMessageItem!
                                .showFromAndBody(),
                        onTap: () {
                          _groupProvider.initialise(groupProviderItem);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                      );
                    }),
                if (!_groupListProvider.lastGroupLoaded)
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
    _groupListProvider.disposeEverything();
    super.dispose();
  }
}
