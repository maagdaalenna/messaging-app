import 'package:Fam.ly/modules/shared/widgets/placeholder_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';

class MemberTile extends StatelessWidget {
  final String name;
  final String email;

  const MemberTile({
    Key? key,
    required this.name,
    required this.email,
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
      // onTap: () {},
      leading: PlaceholderProfilePicture(size: themeSizes.iconLargest),
      title: Text(
        name,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        maxLines: 1,
        email,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.colorScheme.onBackground,
        ),
      ),
    );
  }
}
