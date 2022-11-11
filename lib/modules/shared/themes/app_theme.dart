import 'package:flutter/material.dart';
import 'package:messaging_app/modules/shared/themes/extensions/theme_sizes_extension.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme get colorScheme => const ColorScheme.dark().copyWith(
        primary: const Color(0xff3d8182),
        onPrimary: const Color(0xffffffff),
        secondary: const Color(0xff2d6162),
        onSecondary: const Color(0x9affffff),
        tertiary: const Color(0xff262d34),
        onTertiary: const Color(0xff95a1ac),
        error: const Color(0xffbf360c),
        onError: const Color(0xffffffff),
        errorContainer: const Color(0xffff948c),
        onErrorContainer: const Color(0xffffffff),
        background: const Color(0xff131619),
        onBackground: const Color(0xffffffff),
        shadow: const Color(0x88000000),
      );

  static ThemeSizesExtension get themeSizes => const ThemeSizesExtension(
        spacingSmallest: 4,
        spacingSmaller: 8,
        spacingSmall: 12,
        spacingMedium: 16,
        spacingLarge: 24,
        spacingLarger: 32,
        spacingLargest: 48,
        iconSmallest: 12,
        iconSmaller: 16,
        iconSmall: 20,
        iconMedium: 24,
        iconLarge: 28,
        iconLarger: 32,
        iconLargest: 40,
        borderWidthSmall: .5,
        borderWidthMedium: 1,
        borderWidthLarge: 2,
        buttonSmall: 36,
        buttonMedium: 48,
        buttonLarge: 56,
        borderRadius: 8,
      );

  static TextTheme get textTheme => Typography.englishLike2021;

  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        extensions: [
          themeSizes,
        ],
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(
            horizontal: themeSizes.spacingMedium,
            vertical: 0,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSecondary,
          ),
          labelStyle: TextStyle(
            color: colorScheme.background,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(themeSizes.borderRadius),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(themeSizes.borderRadius),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
              colorScheme.primary,
            ),
            foregroundColor: MaterialStateProperty.all(
              colorScheme.onPrimary,
            ),
            minimumSize: MaterialStateProperty.all(
              Size.fromHeight(
                themeSizes.buttonMedium,
              ),
            ),
            textStyle: MaterialStateProperty.all(
              TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(
              colorScheme.onBackground,
            ),
          ),
        ),
      );
}
