import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme get colorScheme => const ColorScheme.dark().copyWith(
        primary: const Color(0xff3d8182),
        onPrimary: const Color(0xffffffff),
        secondary: const Color(0xff2d6162),
        onSecondary: const Color(0xff95a1ac),
        error: const Color(0xffd32f2f),
        onError: const Color(0xffffffff),
        errorContainer: const Color(0xffff948c),
        onErrorContainer: const Color(0xffffffff),
        background: const Color(0xff131619),
        onBackground: const Color(0xffffffff),
        shadow: const Color(0x88000000),
      );

  static TextTheme get textTheme => Typography.englishLike2018;

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
}
