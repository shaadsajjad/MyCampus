import 'package:flutter/material.dart';

/// Typography scale based on the MyCampus design system.
///
/// These are pure type-scale definitions (size/weight/height/spacing) with
/// no baked-in color, so the same scale can be tinted differently for light
/// and dark themes. `AppTheme.light` / `AppTheme.dark` fold this scale into
/// a `TextTheme` — prefer `Theme.of(context).textTheme` in UI code over
/// referencing these constants directly.
class AppTextStyles {
  new _();

  static const String _fontFamily = 'Inter';

  // ── Display & Headlines ───────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 38 / 30,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
  );

  // ── Titles ────────────────────────────────────────────────────
  static const TextStyle titleMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
  );

  // ── Body ──────────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
  );

  // ── Labels ────────────────────────────────────────────────────
  static const TextStyle labelLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.01,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: 0.02,
  );
}
