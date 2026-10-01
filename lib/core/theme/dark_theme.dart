import 'package:flutter/material.dart';

import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/text_styles.dart';

class DarkTheme {
  new _();

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF90A8FF),
      onPrimary: const Color(0xFF00164E),
      primaryContainer: const Color(0xFF1E3A8A),
      onPrimaryContainer: const Color(0xFFDCE1FF),
      secondary: const Color(0xFFB4C5FF),
      onSecondary: const Color(0xFF00174B),
      secondaryContainer: const Color(0xFF2563EB),
      onSecondaryContainer: const Color(0xFFDBE1FF),
      tertiary: const Color(0xFFFFB77D),
      onTertiary: const Color(0xFF2F1500),
      tertiaryContainer: const Color(0xFF653400),
      onTertiaryContainer: const Color(0xFFFFDCC3),
      surface: const Color(0xFF0F172A),
      onSurface: const Color(0xFFE2E8F0),
      surfaceContainerHighest: const Color(0xFF1E293B),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.display.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLg.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineLgMobile.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSm.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.headlineMd.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMd.copyWith(color: colorScheme.onSurface),
      bodyLarge: AppTextStyles.bodyLg.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      bodyMedium: AppTextStyles.bodyMd.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      bodySmall: AppTextStyles.bodySm.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: AppTextStyles.labelLg.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTextStyles.labelMd.copyWith(color: colorScheme.onSurface),
      labelSmall: AppTextStyles.labelSm.copyWith(color: colorScheme.onSurface),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      fontFamily: 'Inter',
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFE2E8F0),
        titleTextStyle: textTheme.headlineSmall,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90A8FF),
          foregroundColor: const Color(0xFF00164E),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: const Color(0xFFB4C5FF),
          side: const BorderSide(color: Color(0xFF475569)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF90A8FF),
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF90A8FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        labelStyle: AppTextStyles.bodyMd.copyWith(
          color: const Color(0xFF94A3B8),
        ),
        floatingLabelStyle: AppTextStyles.bodyMd.copyWith(
          color: const Color(0xFF90A8FF),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        margin: EdgeInsets.zero,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF90A8FF),
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: AppTextStyles.labelSm.copyWith(
          color: const Color(0xFFE2E8F0),
        ),
        side: const BorderSide(color: Color(0xFF475569)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFFE2E8F0),
        contentTextStyle: AppTextStyles.bodyMd.copyWith(
          color: const Color(0xFF0F172A),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
    );
  }
}
