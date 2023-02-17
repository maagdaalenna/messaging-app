import 'package:Fam.ly/modules/main/classes/firestore_user_item.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:Fam.ly/modules/main/providers/groups_provider.dart';
import 'package:Fam.ly/modules/main/widgets/member_tile.dart';
import 'package:Fam.ly/modules/shared/classes/firestore_user.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:Fam.ly/modules/shared/widgets/placeholder_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late GroupsProvider _groupsProvider;
  PagingController<FirestoreUser?, FirestoreUserItem> _pagingController =
      PagingController(firstPageKey: null);
  final _pageSize = 15;

  Future<void> _fetchPage(
    FirestoreUser? pageKey,
  ) async {
    try {
      final newMembers = await _groupsProvider.getMembersForCurrentGroup(
        pageKey,
        _pageSize,
      );

      List<FirestoreUserItem> newFirestoreUserItems = [];

      for (FirestoreUser member in newMembers) {
        newFirestoreUserItems.add(
          FirestoreUserItem(
            firestoreUser: member,
          ),
        );
      }
      setState(() {
        final isLastPage = newMembers.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newFirestoreUserItems);
        } else {
          final nextPageKey = newMembers.last;
          _pagingController.appendPage(newFirestoreUserItems, nextPageKey);
        }
      });
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupsProvider = Provider.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: themeSizes.spacingMedium),
          child: IconButton(
            icon: Icon(Icons.chevron_left_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: themeSizes.spacingMedium),
            child: IconButton(
              onPressed: () {},
              icon: Icon(FontAwesomeIcons.arrowRightFromBracket),
            ),
          ),
        ],
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          _groupsProvider.currentGroup!.name,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: themeSizes.iconSmall,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: themeSizes.spacingMedium),
            FractionallySizedBox(
              widthFactor: 0.33,
              child: PlaceholderProfilePicture(),
            ),
            SizedBox(height: themeSizes.spacingSmall),
            Padding(
              padding: EdgeInsets.only(
                left: themeSizes.spacingMedium,
                right: themeSizes.spacingMedium,
              ),
              child: Text(
                _groupsProvider.currentGroup!.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: themeSizes.spacingLarge),
            Padding(
              padding: EdgeInsets.only(
                left: themeSizes.spacingMedium,
                right: themeSizes.spacingMedium,
              ),
              child: Row(
                children: [
                  Text(
                    "Members:",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            PagedListView<FirestoreUser?, FirestoreUserItem>(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<FirestoreUserItem>(
                itemBuilder: (context, firestoreUserItem, index) => MemberTile(
                  name: firestoreUserItem.firestoreUser.displayName,
                  email: firestoreUserItem.firestoreUser.email,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
