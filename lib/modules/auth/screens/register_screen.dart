import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Container(
                    color: theme.colorScheme.background,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: themeSizes.spacingLargest,
                        ),
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.2,
                            child: Image(
                              image: AssetImage("assets/images/famly-logo.png"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSizes.spacingLarge,
                      vertical: themeSizes.spacingLarger,
                    ),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Enter your name here...",
                              label: Text("Full Name"),
                            ),
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Enter your email here...",
                              label: Text("Email Address"),
                            ),
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextField(
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Enter your password here...",
                              label: Text("Password"),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: FaIcon(
                                  _hidePassword
                                      ? FontAwesomeIcons.solidEyeSlash
                                      : FontAwesomeIcons.solidEye,
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextField(
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Confirm your password here...",
                              label: Text("Confirm Password"),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: FaIcon(
                                  _hidePassword
                                      ? FontAwesomeIcons.solidEyeSlash
                                      : FontAwesomeIcons.solidEye,
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Create Account"),
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          Center(
                            child: SizedBox(
                              width: themeSizes.buttonMedium,
                              height: themeSizes.buttonMedium,
                              child: IconButton(
                                onPressed: () {},
                                icon: FaIcon(
                                  FontAwesomeIcons.google,
                                  color: theme.colorScheme.background,
                                  size: themeSizes.iconLarger,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already a member?",
                                style: TextStyle(
                                  color: theme.colorScheme.background,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text("Login"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
