import 'package:firstpay/app/theme/firstpay_colors.dart';
import 'package:firstpay/app/theme/firstpay_spacing.dart';
import 'package:flutter/material.dart';

abstract final class FirstPayTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: FirstPayColors.primaryNavy,
      brightness: Brightness.light,
      primary: FirstPayColors.primaryNavy,
      secondary: FirstPayColors.successGreen,
      error: FirstPayColors.error,
      surface: FirstPayColors.white,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FirstPaySpacing.cardRadius),
      borderSide: const BorderSide(color: FirstPayColors.border),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FirstPayColors.background,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: FirstPayColors.white,
        foregroundColor: FirstPayColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: FirstPayColors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FirstPaySpacing.cardRadius),
          side: const BorderSide(color: FirstPayColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FirstPayColors.white,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: FirstPayColors.primaryNavy,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, FirstPaySpacing.controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FirstPaySpacing.cardRadius),
          ),
        ),
      ),
    );
  }
}
