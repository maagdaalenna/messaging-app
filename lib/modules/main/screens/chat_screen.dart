import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:Fam.ly/modules/main/providers/group_chat_provider.dart';
import 'package:Fam.ly/modules/main/widgets/message_tile.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GroupChatProvider _groupChatProvider;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _groupChatProvider.cancelEventsSubscription();
    super.dispose();
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
              child: (_groupChatProvider.pagingController.itemList == null
                      ? false
                      : _groupChatProvider.pagingController.itemList!.isEmpty)
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
                  : PagedListView<GroupMessage?, MessageItem>(
                      reverse: true,
                      pagingController: _groupChatProvider.pagingController,
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
                      controller: _messageController,
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
                    onPressed: () {
                      var groupMessage = GroupMessage(
                        body: _messageController.text,
                        from: _groupChatProvider.currentUser,
                        datetime: DateTime.now(),
                      );
                      _groupChatProvider
                          .addMessageForCurrentGroup(groupMessage);
                      _messageController.clear();
                    },
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
