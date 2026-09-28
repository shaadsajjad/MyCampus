import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration based on the MyCampus design system.
class AppTheme {
  AppTheme._();

  // ── Border Radii ──────────────────────────────────────────────
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 9999;

  // ── Spacing ───────────────────────────────────────────────────
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get light => LightTheme.theme;
  static ThemeData get dark => DarkTheme.theme;
}

// Re-exports for convenience
export 'light_theme.dart';
export 'dark_theme.dart';
