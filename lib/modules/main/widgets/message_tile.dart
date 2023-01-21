import 'package:flutter/material.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class MessageTile extends StatelessWidget {
  final String header;
  final String body;

  const MessageTile({
    Key? key,
    required String this.header,
    required String this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return Padding(
      padding: EdgeInsets.all(themeSizes.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header),
          Row(
            children: [
              Text("|  "),
              Text(body),
            ],
          ),
        ],
      ),
    );
  }
}
