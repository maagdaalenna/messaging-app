import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return Padding(
      padding: EdgeInsets.all(themeSizes.spacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Please fill in the required details about the family group.",
          ),
          SizedBox(height: themeSizes.spacingMedium),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.background,
              hintStyle: TextStyle(
                color: theme.colorScheme.onBackground,
              ),
              labelStyle: TextStyle(
                color: theme.colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(themeSizes.borderRadius),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
              hintText: "Enter the family's name here...",
              label: Text("Family Name"),
            ),
          ),
          SizedBox(height: themeSizes.spacingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
              ),
              SizedBox(width: themeSizes.spacingMedium),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Bejan Family successfully created!"),
                      content: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Share this code with your family:"),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: themeSizes.spacingSmaller),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          themeSizes.borderRadius),
                                      border: Border.all(
                                          color:
                                              theme.colorScheme.onBackground)),
                                  child: SelectableText(
                                    "Af4EsW",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.share),
                                  onPressed: () async {
                                    await FlutterShare.share(
                                      title: "Share",
                                      text: "Af4EsW",
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // cascade notation
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          },
                          child: const Text("Let's go!"),
                        ),
                      ],
                    ),
                  ),
                  child: Text("Continue"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
