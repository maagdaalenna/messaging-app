import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/classes/group_item.dart';
import 'package:Fam.ly/modules/main/providers/group_chat_provider.dart';
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
  late GroupChatProvider _groupChatProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupsProvider = Provider.of(context);
    _groupChatProvider = Provider.of(context);

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
      body: (_groupsProvider.pagingController.itemList == null
              ? false
              : _groupsProvider.pagingController.itemList!.isEmpty)
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
          : PagedListView<Group?, GroupItem>(
              pagingController: _groupsProvider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<GroupItem>(
                itemBuilder: (context, groupItem, index) => ListTile(
                  contentPadding: EdgeInsets.only(
                    left: themeSizes.spacingMedium,
                    right: themeSizes.spacingMedium,
                  ),
                  onTap: () {
                    _groupChatProvider.initialise(groupItem.group);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  leading: CircleAvatar(radius: 24),
                  title: Text(groupItem.group.name),
                  subtitle: Text(
                    groupItem.showUserAndMessage(),
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: null, // solves the heroes error
        onPressed: () {},
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
    _groupsProvider.cancelEventsSubscription();
    super.dispose();
  }
}

/*

bool condition = _pagingController.itemList? == null ? false : _pagingController.itemList!.isEmpty

if (condition) {

} else {

}

*/