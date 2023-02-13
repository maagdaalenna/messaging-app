import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Fam.ly/modules/auth/providers/auth_provider.dart';
import 'package:Fam.ly/modules/auth/providers/email_provider.dart';
import 'package:Fam.ly/modules/shared/themes/extensions/theme_sizes_extension.dart';
import 'package:provider/provider.dart';

class ConfirmAccountScreen extends StatefulWidget {
  const ConfirmAccountScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmAccountScreen> createState() => _ConfirmAccountScreenState();
}

class _ConfirmAccountScreenState extends State<ConfirmAccountScreen> {
  late EmailProvider _emailProvider;
  late AuthProvider _authProvider;

  late Timer _resendCooldownTimer;
  int _resendCooldown = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    final themeSizes = theme.extension<ThemeSizesExtension>()!;
    _emailProvider = Provider.of(context);
    _authProvider = Provider.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Padding(
          padding: EdgeInsets.all(themeSizes.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Email not yet confirmed",
                textAlign: TextAlign.center,
              ),
              Text(
                "We sent an email to",
                textAlign: TextAlign.center,
              ),
              Text(
                "${_authProvider.user!.email}",
                textAlign: TextAlign.center,
              ),
              Text(
                "Confirm your email to continue",
                textAlign: TextAlign.center,
              ),
              _resendCooldown != 0
                  ? TextButton(
                      onPressed: null,
                      child: Text("Resend email (${_resendCooldown})"),
                    )
                  : TextButton(
                      onPressed: () {
                        _emailProvider.sendEmailVerification();
                        _startTimer();
                      },
                      child: Text("Resend email"),
                    ),
              Text(
                "Finished confirming your email?",
                textAlign: TextAlign.center,
              ),
              _authProvider.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _authProvider.logout();
                            },
                            child: Text("Cancel"),
                          ),
                        ),
                        SizedBox(width: themeSizes.spacingSmaller),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _authProvider.reload();
                            },
                            child: Text("Continue"),
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

  @override
  void dispose() {
    _resendCooldownTimer.cancel();
    super.dispose();
  }
}
