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
      body: !_groupsProvider.firstGroupLoaded
          ? Center(child: CircularProgressIndicator())
          : (_groupsProvider.groups.isEmpty)
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
                  itemCount: _groupsProvider.groups.length,
                  itemBuilder: (BuildContext context, int index) {
                    var group = _groupsProvider.groups[index];
                    return ListTile(
                      contentPadding: EdgeInsets.only(
                        left: themeSizes.spacingMedium,
                        right: themeSizes.spacingMedium,
                      ),
                      onTap: () {
                        _groupsProvider.initialise(index);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      leading: PlaceholderProfilePicture(),
                      title: Text(group.name),
                      subtitle: Text(
                        _groupsProvider
                                .pagingControllerList[index].itemList![0].from +
                            ": " +
                            _groupsProvider
                                .pagingControllerList[index].itemList![0].body,
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),
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
    _groupsProvider.disposeEverything();
    super.dispose();
  }
}

/*

bool condition = _pagingController.itemList? == null ? false : _pagingController.itemList!.isEmpty

if (condition) {

} else {

}

*/