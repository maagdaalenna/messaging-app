import 'dart:ui';

import 'package:flutter/material.dart';

class ThemeSizesExtension extends ThemeExtension<ThemeSizesExtension> {
  // Spacing
  final double spacingSmallest;
  final double spacingSmaller;
  final double spacingSmall;
  final double spacingMedium;
  final double spacingLarge;
  final double spacingLarger;
  final double spacingLargest;

  // Icons
  final double iconSmallest;
  final double iconSmaller;
  final double iconSmall;
  final double iconMedium;
  final double iconLarge;
  final double iconLarger;
  final double iconLargest;

  // Border
  final double borderWidthSmall;
  final double borderWidthMedium;
  final double borderWidthLarge;

  // Buttons
  final double buttonSmall;
  final double buttonMedium;
  final double buttonLarge;

  // Misc
  final double borderRadius;

  // Constructors
  const ThemeSizesExtension({
    required this.spacingSmallest,
    required this.spacingSmaller,
    required this.spacingSmall,
    required this.spacingMedium,
    required this.spacingLarge,
    required this.spacingLarger,
    required this.spacingLargest,
    required this.iconSmallest,
    required this.iconSmaller,
    required this.iconSmall,
    required this.iconMedium,
    required this.iconLarge,
    required this.iconLarger,
    required this.iconLargest,
    required this.borderWidthSmall,
    required this.borderWidthMedium,
    required this.borderWidthLarge,
    required this.buttonSmall,
    required this.buttonMedium,
    required this.buttonLarge,
    required this.borderRadius,
  });

  @override
  ThemeExtension<ThemeSizesExtension> copyWith({
    double? spacingSmallest,
    double? spacingSmaller,
    double? spacingSmall,
    double? spacingMedium,
    double? spacingLarge,
    double? spacingLarger,
    double? spacingLargest,
    double? iconSmallest,
    double? iconSmaller,
    double? iconSmall,
    double? iconMedium,
    double? iconLarge,
    double? iconLarger,
    double? iconLargest,
    double? borderWidthSmall,
    double? borderWidthMedium,
    double? borderWidthLarge,
    double? buttonSmall,
    double? buttonMedium,
    double? buttonLarge,
    double? borderRadius,
  }) {
    return ThemeSizesExtension(
      spacingSmallest: spacingSmallest ?? this.spacingSmallest,
      spacingSmaller: spacingSmaller ?? this.spacingSmaller,
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingMedium: spacingMedium ?? this.spacingMedium,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      spacingLarger: spacingLarger ?? this.spacingLarger,
      spacingLargest: spacingLargest ?? this.spacingLargest,
      iconSmallest: iconSmallest ?? this.iconSmallest,
      iconSmaller: iconSmaller ?? this.iconSmaller,
      iconSmall: iconSmall ?? this.iconSmall,
      iconMedium: iconMedium ?? this.iconMedium,
      iconLarge: iconLarge ?? this.iconLarge,
      iconLarger: iconLarger ?? this.iconLarger,
      iconLargest: iconLargest ?? this.iconLargest,
      borderWidthSmall: borderWidthSmall ?? this.borderWidthSmall,
      borderWidthMedium: borderWidthMedium ?? this.borderWidthMedium,
      borderWidthLarge: borderWidthLarge ?? this.borderWidthLarge,
      buttonSmall: buttonSmall ?? this.buttonSmall,
      buttonMedium: buttonMedium ?? this.buttonMedium,
      buttonLarge: buttonLarge ?? this.buttonLarge,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  ThemeExtension<ThemeSizesExtension> lerp(
      ThemeExtension<ThemeSizesExtension>? other, double t) {
    other as ThemeSizesExtension?;
    other ??= this;
    return ThemeSizesExtension(
      spacingSmallest: lerpDouble(spacingSmallest, other.spacingSmallest, t)!,
      spacingSmaller: lerpDouble(spacingSmaller, other.spacingSmaller, t)!,
      spacingSmall: lerpDouble(spacingSmall, other.spacingSmall, t)!,
      spacingMedium: lerpDouble(spacingMedium, other.spacingMedium, t)!,
      spacingLarge: lerpDouble(spacingLarge, other.spacingLarge, t)!,
      spacingLarger: lerpDouble(spacingLarger, other.spacingLarger, t)!,
      spacingLargest: lerpDouble(spacingLargest, other.spacingLargest, t)!,
      iconSmallest: lerpDouble(iconSmallest, other.iconSmallest, t)!,
      iconSmaller: lerpDouble(iconSmaller, other.iconSmaller, t)!,
      iconSmall: lerpDouble(iconSmall, other.iconSmall, t)!,
      iconMedium: lerpDouble(iconMedium, other.iconMedium, t)!,
      iconLarge: lerpDouble(iconLarge, other.iconLarge, t)!,
      iconLarger: lerpDouble(iconLarger, other.iconLarger, t)!,
      iconLargest: lerpDouble(iconLargest, other.iconLargest, t)!,
      borderWidthSmall:
          lerpDouble(borderWidthSmall, other.borderWidthSmall, t)!,
      borderWidthMedium:
          lerpDouble(borderWidthMedium, other.borderWidthMedium, t)!,
      borderWidthLarge:
          lerpDouble(borderWidthLarge, other.borderWidthLarge, t)!,
      buttonSmall: lerpDouble(buttonSmall, other.buttonSmall, t)!,
      buttonMedium: lerpDouble(buttonMedium, other.buttonMedium, t)!,
      buttonLarge: lerpDouble(buttonLarge, other.buttonLarge, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}
