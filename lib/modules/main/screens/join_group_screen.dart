import 'package:Fam.ly/modules/main/classes/group.dart';
import 'package:Fam.ly/modules/main/providers/group_list_provider.dart';
import 'package:Fam.ly/modules/main/providers/group_operations_provider.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:Fam.ly/modules/shared/widgets/famly_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({Key? key}) : super(key: key);

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  late GroupOperationsProvider _joinCreateGroupProvider;
  late GroupListProvider _groupListProvider;
  final _formKey = GlobalKey<FormState>();
  final _familyCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _joinCreateGroupProvider = Provider.of(context);
    _groupListProvider = Provider.of(context);

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
                controller: _familyCodeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter the family code!";
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
                  hintText: "Enter the family's code here...",
                  label: Text("Family Code"),
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
                                String groupId = _familyCodeController.text;
                                _familyCodeController.clear();
                                _joinCreateGroupProvider
                                    .joinGroup(groupId)
                                    .then(
                                  (value) {
                                    if (_joinCreateGroupProvider.error ==
                                        null) {
                                      Group group = _joinCreateGroupProvider
                                          .result! as Group;
                                      _groupListProvider.addGroup(group);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                "Successfully joined ${group.name}!"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .popUntil(
                                                    (route) {
                                                      return !Navigator.of(
                                                              context)
                                                          .canPop();
                                                    },
                                                  );
                                                },
                                                child: const Text("Continue"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              _joinCreateGroupProvider.error!,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("Okay"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                );
                              }
                            },
                      child: _joinCreateGroupProvider.loading
                          ? CircularProgressIndicator()
                          : Text("Join"),
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
