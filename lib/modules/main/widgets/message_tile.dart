import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';

class MessageTile extends StatelessWidget {
  final String header;
  final String body;
  final bool onRight;

  const MessageTile({
    Key? key,
    required this.header,
    required this.body,
    this.onRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return Padding(
      padding: EdgeInsets.all(themeSizes.spacingMedium),
      child: Column(
        crossAxisAlignment:
            onRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          IntrinsicHeight(
            child: onRight
                ? Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Text(
                            body,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              overflow: TextOverflow.clip,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 12,
                        thickness: 1,
                        indent: 2,
                        endIndent: 0,
                        color: Colors.white,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      VerticalDivider(
                        width: 12,
                        thickness: 1,
                        indent: 2,
                        endIndent: 0,
                        color: theme.colorScheme.onBackground,
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Text(
                            body,
                            style: TextStyle(
                              overflow: TextOverflow.clip,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
