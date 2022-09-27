import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthProvider _authProvider;
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!; // is not null
    _authProvider = Provider.of(context);

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
                              hintText: "Your email...",
                              label: Text("Email Address"),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: theme.colorScheme.primary,
                              ),
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
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: theme.colorScheme.primary,
                              ),
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
                            child: Text("Login"),
                          ),
                          SizedBox(height: themeSizes.spacingSmaller),
                          TextButton(
                            onPressed: () {},
                            child: Text("Forgot password?"),
                          ),
                          SizedBox(height: themeSizes.spacingSmaller),
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
                                // icon: Image(
                                //   image:
                                //       AssetImage("assets/images/google-logo.png"),
                                // ),
                              ),
                            ),
                          ),
                          SizedBox(height: themeSizes.spacingSmaller),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account yet?",
                                style: TextStyle(
                                  color: theme.colorScheme.background,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _authProvider.setRegisterPageActive();
                                },
                                child: Text("Register"),
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
