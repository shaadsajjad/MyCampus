import 'package:flutter/material.dart';

/// App color palette based on the MyCampus design system.
/// Reference: Stitch design guide - Academic Modernity
class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimaryContainer = Color(0xFF90A8FF);

  static const Color secondary = Color(0xFF2563EB); // Royal Blue
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF316BF3);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);

  static const Color tertiary = Color(0xFFD97706); // Academic Amber
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF653400);
  static const Color onTertiaryContainer = Color(0xFFFC922B);

  // ── Neutral / Surface ─────────────────────────────────────────
  static const Color surface = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerHigh = Color(0xFFE5EEFF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  static const Color onSurface = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceVariant = Color(0xFF475569); // Slate 600
  static const Color outline = Color(0xFFE2E8F0); // Slate 200
  static const Color outlineVariant = Color(0xFFC5C5D3);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // ── Onboarding Brand Accents ──────────────────────────────────
  /// Pale blue tint behind the brand header and a selected role card.
  static const Color brandTint = Color(0xFFEFF4FF);

  /// Deep indigo text used on [brandTint] badges (official badge, step
  /// indicator, and the super-admin/student role badges).
  static const Color brandAccentText = Color(0xFF264191);

  // ── Elevation Shadows ─────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
