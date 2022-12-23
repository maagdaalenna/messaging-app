import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:messaging_app/modules/main/classes/group.dart';
import 'package:messaging_app/modules/main/classes/group_item.dart';
import 'package:messaging_app/modules/main/providers/group_chat_provider.dart';
import 'package:messaging_app/modules/main/providers/groups_provider.dart';
import 'package:messaging_app/modules/main/screens/chat_screen.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class FamilyChatsScreen extends StatefulWidget {
  const FamilyChatsScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatsScreen> createState() => _FamilyChatsScreenState();
}

class _FamilyChatsScreenState extends State<FamilyChatsScreen> {
  late GroupsProvider _groupsProvider;
  late GroupChatProvider _groupChatProvider;

  // 20 items per page
  static const _pageSize = 20;

  // we need a controller for the infinite list view
  final PagingController<Group?, GroupItem> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(Group? pageKey) async {
    try {
      final newGroups = await _groupsProvider.getGroupsForCurrentUser(
        pageKey,
        _pageSize,
      );

      List<GroupItem> newGroupItems = [];

      for (Group group in newGroups) {
        var lastMessage = await _groupsProvider.getLastMessage(group.id!);
        newGroupItems.add(GroupItem(
          group: group,
          from: lastMessage.from.displayName,
          lastMessage: lastMessage.body,
        ));
      }
      final isLastPage = newGroups.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newGroupItems);
      } else {
        final nextPageKey = newGroups[-1];
        _pagingController.appendPage(newGroupItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

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
      body: (_pagingController.itemList == null
              ? false
              : _pagingController.itemList!.isEmpty)
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
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<GroupItem>(
                itemBuilder: (context, groupItem, index) => ListTile(
                  contentPadding: EdgeInsets.only(
                    left: themeSizes.spacingMedium,
                    right: themeSizes.spacingMedium,
                  ),
                  onTap: () {
                    _groupChatProvider.currentGroup = groupItem.group;
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
                    style: TextStyle(color: theme.colorScheme.onSecondary),
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
    _pagingController.dispose();
    super.dispose();
  }
}

/*

bool condition = _pagingController.itemList? == null ? false : _pagingController.itemList!.isEmpty

if (condition) {

} else {

}

*/