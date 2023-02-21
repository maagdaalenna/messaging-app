import 'package:Fam.ly/modules/main/providers/group_list_provider.dart';
import 'package:Fam.ly/modules/main/providers/group_provider.dart';
import 'package:Fam.ly/modules/main/screens/group_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:Fam.ly/modules/main/classes/group_message.dart';
import 'package:Fam.ly/modules/main/classes/message_item.dart';
import 'package:Fam.ly/modules/main/widgets/message_tile.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late GroupProvider _groupProvider;
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _groupProvider = Provider.of(context);

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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroupDetailsScreen(),
              ),
            );
          },
          child: Text(
            _groupProvider.currentGroup!.name,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: themeSizes.iconSmall,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: (_groupProvider.currentPagingController!.itemList == null
                    ? false
                    : _groupProvider.currentPagingController!.itemList!.isEmpty)
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
                    pagingController: _groupProvider.currentPagingController!,
                    builderDelegate: PagedChildBuilderDelegate<MessageItem>(
                      itemBuilder: (context, messageItem, index) => MessageTile(
                        onRight: messageItem.isFromCurrentUser,
                        header: messageItem.showFromAndDate(),
                        body: messageItem.groupMessage.body,
                      ),
                    ),
                  ),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(themeSizes.spacingSmall),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_sharp),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      controller: _messageController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().isEmpty) {
                          return "";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: TextStyle(height: 0.01),
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
                    iconSize: 32,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        var groupMessage = GroupMessage(
                          body: _messageController.text,
                          from: _groupProvider.currentUser,
                          datetime: DateTime.now(),
                        );
                        _groupProvider.addMessageForCurrentGroup(groupMessage);
                        _messageController.clear();
                      }
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
