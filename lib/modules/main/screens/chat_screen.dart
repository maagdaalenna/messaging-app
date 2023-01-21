import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:messaging_app/modules/main/classes/message.dart';
import 'package:messaging_app/modules/main/classes/message_item.dart';
import 'package:messaging_app/modules/main/providers/group_chat_provider.dart';
import 'package:messaging_app/modules/main/widgets/message_tile.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GroupChatProvider _groupChatProvider;

  // 20 items per page
  static const _pageSize = 30;

  // we need a controller for the infinite list view
  final PagingController<Message?, MessageItem> _pagingController =
      PagingController(firstPageKey: null);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(Message? pageKey) async {
    try {
      final newMessages = await _groupChatProvider.getMessagesForCurrentGroup(
        pageKey,
        _pageSize,
      );

      List<MessageItem> newMessageItems = [];

      for (Message message in newMessages) {
        newMessageItems.add(MessageItem(
          body: message.body,
          from: (_groupChatProvider.currentUser.uid != message.from.id)
              ? message.from.displayName
              : "You",
          time: message.datetime.hour.toString() +
              ":" +
              message.datetime.minute.toString(),
        ));
      }
      final isLastPage = newMessages.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newMessageItems);
      } else {
        final nextPageKey = newMessages[-1];
        _pagingController.appendPage(newMessageItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupChatProvider = Provider.of(context);

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
              icon: Icon(Icons.call),
            ),
          ),
        ],
        backgroundColor: theme.colorScheme.primary,
        title: TextButton(
          onPressed: () {},
          child: Text(
            _groupChatProvider.currentGroup!.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: themeSizes.spacingSmall,
        ),
        child: Column(
          children: [
            Expanded(
              child: (_pagingController.itemList == null
                      ? false
                      : _pagingController.itemList!.isEmpty)
                  ? Padding(
                      padding: EdgeInsets.all(themeSizes.spacingLarge),
                      child: Center(
                        child: Text(
                          "There are no messages to show!",
                          style: TextStyle(
                            fontSize: 20,
                            color: theme.colorScheme.onSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : PagedListView<Message?, MessageItem>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<MessageItem>(
                        itemBuilder: (context, messageItem, index) =>
                            MessageTile(
                          header: messageItem.showFromAndDate(),
                          body: messageItem.body,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: themeSizes.spacingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_sharp),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.tertiary,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onTertiary,
                        ),
                        label: Text("Message"),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.attach_file),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: themeSizes.spacingSmaller,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
