import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:messaging_app/modules/auth/classes/login_credentials.dart';
import 'package:messaging_app/modules/auth/providers/auth_navigation_provider.dart';
import 'package:messaging_app/modules/auth/providers/auth_provider.dart';
import 'package:messaging_app/modules/auth/providers/email_provider.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthProvider _authProvider;
  late AuthNavigationProvider _authNavigationProvider;
  late EmailProvider _emailProvider;
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailAdressController = TextEditingController();
  final _passwordController = TextEditingController();

  late Timer _resendCooldownTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _resendCooldownTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {},
    );
    _resendCooldownTimer.cancel();
  }

  void _startTimer() {
    setState(() {
      _resendCooldown = 10;
    });
    _resendCooldownTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            _resendCooldown--;
          });
          if (_resendCooldown == 0) {
            _resendCooldownTimer.cancel();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSizes = theme.extension<ThemeSizesExtension>()!; // is not null
    _authProvider = Provider.of(context);
    _authNavigationProvider = Provider.of(context, listen: false);
    _emailProvider = Provider.of(context);

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
                            controller: _emailAdressController,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your email adress!";
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your password!";
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
                                LoginCredentials credentials = LoginCredentials(
                                  _emailAdressController.text,
                                  _passwordController.text,
                                );
                                _authProvider.login(credentials);
                              }
                            },
                            child: _authProvider.loading
                                ? CircularProgressIndicator()
                                : Text("Login"),
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
                          SizedBox(height: themeSizes.spacingSmaller),
                          _resendCooldown != 0
                              ? TextButton(
                                  onPressed: null,
                                  child: Text(
                                      "Forgot password? (${_resendCooldown})"),
                                )
                              : TextButton(
                                  onPressed: () {
                                    _emailProvider.sendPasswordResetEmail(
                                        _emailAdressController.text);
                                    _startTimer();
                                  },
                                  child: Text("Forgot password?"),
                                ),
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
                                  _authNavigationProvider
                                      .setRegisterPageActive();
                                  _authProvider.error = null;
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

  @override
  void dispose() {
    _emailAdressController.dispose();
    _passwordController.dispose();
    _resendCooldownTimer.cancel();
    super.dispose();
  }
}
