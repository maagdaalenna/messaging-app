import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:flutter/material.dart';

class PlaceholderProfilePicture extends StatelessWidget {
  final double? size;
  const PlaceholderProfilePicture({
    Key? key,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    // return CircleAvatar(radius: 24);

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(themeSizes.borderRadius)),
      child: SizedBox.square(
        dimension: size,
        child: Image(
          image: AssetImage("assets/images/placeholder-profile-picture.jpg"),
        ),
      ),
    );
  }
}
