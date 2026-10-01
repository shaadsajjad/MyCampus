import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/dark_theme.dart';
import 'package:mycampus/core/theme/light_theme.dart';

export 'dark_theme.dart';
export 'light_theme.dart';

/// App theme configuration based on the MyCampus design system.
class AppTheme {
  new _();

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

  // ── Motion ────────────────────────────────────────────────────
  /// Duration for small interactive state changes (selection, toggles).
  static const Duration durationFast = Duration(milliseconds: 200);

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get light => LightTheme.theme;
  static ThemeData get dark => DarkTheme.theme;
}
