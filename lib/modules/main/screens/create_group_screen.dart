import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/providers/group_list_provider.dart';
import 'package:Fam.ly/modules/main/providers/group_operations_provider.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:Fam.ly/modules/shared/widgets/famly_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late GroupOperationsProvider _joinCreateGroupProvider;
  late GroupListProvider _groupsProvider;
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _joinCreateGroupProvider = Provider.of(context);
    _groupsProvider = Provider.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: themeSizes.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: themeSizes.spacingLargest),
              FractionallySizedBox(
                widthFactor: 0.2,
                child: FamlyLogo(),
              ),
              SizedBox(height: themeSizes.spacingLargest),
              TextFormField(
                controller: _familyNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the family name!";
                  }
                  return null;
                },
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
                    borderRadius:
                        BorderRadius.circular(themeSizes.borderRadius),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  hintText: "Enter the family's name here...",
                  label: Text("Family Name"),
                ),
              ),
              SizedBox(height: themeSizes.spacingSmall),
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
                  SizedBox(width: themeSizes.spacingSmall),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _joinCreateGroupProvider.loading
                          ? () {}
                          : () {
                              if (_formKey.currentState!.validate()) {
                                String name = _familyNameController.text;
                                _familyNameController.clear();
                                Group group = Group(
                                  name: name,
                                  created: DateTime.now(),
                                );
                                _joinCreateGroupProvider
                                    .createGroup(group)
                                    .then(
                                  (value) {
                                    group.id = _joinCreateGroupProvider.result!
                                        as String;
                                    _groupsProvider.addGroup(group);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              "$name successfully created!"),
                                          content: IntrinsicHeight(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Share this code with your family:"),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: themeSizes
                                                                .spacingSmaller),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    themeSizes
                                                                        .borderRadius),
                                                            border: Border.all(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onBackground)),
                                                        child: SelectableText(
                                                          group.id!,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.share),
                                                      onPressed: () async {
                                                        await FlutterShare
                                                            .share(
                                                          title: "Share",
                                                          text: group.id!,
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
                                                Navigator.of(context).popUntil(
                                                  (route) {
                                                    return Navigator.of(context)
                                                        .canPop();
                                                  },
                                                );
                                              },
                                              child: const Text("Let's go!"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            },
                      child: _joinCreateGroupProvider.loading
                          ? CircularProgressIndicator()
                          : Text("Create"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
