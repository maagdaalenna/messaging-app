import 'package:Fam.ly/modules/main/classes/firestore_user_item.dart';
import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/providers/group_list_provider.dart';
import 'package:Fam.ly/modules/main/providers/group_provider.dart';
import 'package:Fam.ly/modules/main/providers/group_operations_provider.dart';
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
  late GroupListProvider _groupListProvider;
  late GroupProvider _groupProvider;
  late GroupOperationsProvider _joinCreateGroupProvider;
  PagingController<FirestoreUser?, FirestoreUserItem> _pagingController =
      PagingController(firstPageKey: null);
  final int _pageSize = 15;

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
    _groupListProvider = Provider.of(context);
    _groupProvider = Provider.of(context);
    _joinCreateGroupProvider = Provider.of(context);

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
              onPressed: () {
                Group group = _groupProvider.currentGroup!;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          Text("Are you sure you want to leave ${group.name}?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: _joinCreateGroupProvider.loading
                              ? CircularProgressIndicator()
                              : Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            _joinCreateGroupProvider.leaveGroup(group.id!).then(
                              (value) {
                                if (_joinCreateGroupProvider.error == null) {
                                  _groupListProvider.removeGroup(group);
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Successfully leaved ${group.name}!"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).popUntil(
                                                (route) {
                                                  return !Navigator.of(context)
                                                      .canPop();
                                                },
                                              );
                                            },
                                            child: const Text("Okay"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            );
                          },
                          child: _joinCreateGroupProvider.loading
                              ? CircularProgressIndicator()
                              : Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(FontAwesomeIcons.arrowRightFromBracket),
            ),
          ),
        ],
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          _groupProvider.currentGroup!.name,
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
                _groupProvider.currentGroup!.name,
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
                itemBuilder: (context, firestoreUserItem, index) {
                  return MemberTile(
                    name: firestoreUserItem.firestoreUser.displayName,
                    email: firestoreUserItem.firestoreUser.email,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchPage(
    FirestoreUser? pageKey,
  ) async {
    try {
      final newMembers = await _groupProvider.getMembersForCurrentGroup(
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
}
