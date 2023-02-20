import 'package:Fam.ly/modules/shared/widgets/placeholder_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';

class GroupTile extends StatelessWidget {
  final void Function()? onTap;
  final String name;
  final String fromAndBody;

  const GroupTile({
    Key? key,
    this.onTap,
    required this.name,
    required this.fromAndBody,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return ListTile(
      contentPadding: EdgeInsets.only(
        left: themeSizes.spacingMedium,
        right: themeSizes.spacingMedium,
      ),
      onTap: onTap,
      leading: PlaceholderProfilePicture(size: themeSizes.iconLargest),
      title: Text(
        name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        fromAndBody,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }
}
