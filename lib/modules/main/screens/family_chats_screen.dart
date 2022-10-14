import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class FamilyChatsScreen extends StatefulWidget {
  const FamilyChatsScreen({Key? key}) : super(key: key);

  @override
  State<FamilyChatsScreen> createState() => _FamilyChatsScreenState();
}

class _FamilyChatsScreenState extends State<FamilyChatsScreen> {
  final List<String> _cards = [
    for (var i = 1; i <= 50; i++) "Family $i",
  ];

  // 20 items per page
  static const _pageSize = 20;

  // we need a controller for the infinite list view
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<List<String>> getTextList(pageKey, pageSize) async {
    await new Future.delayed(const Duration(seconds: 1));
    if (pageKey + pageSize <= _cards.length)
      return _cards.getRange(pageKey, pageKey + pageSize).toList();
    else
      return _cards.getRange(pageKey, _cards.length).toList();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await getTextList(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

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
      body: _cards.isEmpty
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
          : PagedListView<int, String>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<String>(
                itemBuilder: (context, item, index) => ListTile(
                  contentPadding: EdgeInsets.only(
                    left: themeSizes.spacingMedium,
                    right: themeSizes.spacingMedium,
                  ),
                  onTap: () {},
                  leading: CircleAvatar(radius: 24),
                  title: Text(item),
                  subtitle: Text(
                    "Hello!",
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
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
