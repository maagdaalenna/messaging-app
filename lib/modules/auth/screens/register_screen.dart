import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Fam.ly/modules/auth/classes/register_credentials.dart';
import 'package:Fam.ly/modules/auth/providers/auth_navigation_provider.dart';
import 'package:Fam.ly/modules/auth/providers/auth_provider.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AuthProvider _authProvider;
  late AuthNavigationProvider _authNavigationProvider;
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailAdressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _authProvider = Provider.of(context);
    _authNavigationProvider = Provider.of(context, listen: false);

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
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Enter your name here...",
                              label: Text("Full Name"),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your full name!";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextFormField(
                            controller: _emailAdressController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.secondary,
                              hintText: "Enter your email here...",
                              label: Text("Email Address"),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your email address!";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextFormField(
                            controller: _passwordController,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your password!";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          TextFormField(
                            controller: _confirmPasswordController,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm your password!";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: themeSizes.spacingMedium),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                theme.colorScheme.background,
                              ),
                              foregroundColor: MaterialStateProperty.all(
                                theme.colorScheme.onBackground,
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                RegisterCredentials credentials =
                                    RegisterCredentials(
                                  _emailAdressController.text,
                                  _passwordController.text,
                                  _confirmPasswordController.text,
                                  _displayNameController.text,
                                );
                                _authProvider.register(credentials);
                              }
                            },
                            child: _authProvider.loading
                                ? CircularProgressIndicator()
                                : Text("Create Account"),
                          ),
                          if (_authProvider.error != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: themeSizes.spacingSmaller,
                                left: themeSizes.spacingMedium,
                              ),
                              child: Text(
                                _authProvider.error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
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
                                onPressed: () {
                                  _authNavigationProvider.setLoginPageActive();
                                  _authProvider.error = null;
                                },
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

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailAdressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
