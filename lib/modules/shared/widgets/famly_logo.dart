import 'package:flutter/material.dart';

class FamlyLogo extends StatelessWidget {
  const FamlyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage("assets/images/famly-logo.png"),
    );
  }
}
