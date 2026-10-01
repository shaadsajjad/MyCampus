import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';

/// A centered icon/title/description card with an optional status banner
/// and call-to-action button — used by the student/teacher dashboards for
/// their "not a member yet" / "waiting for approval" states, and generic
/// enough for any future empty-state screen.
class EmptyStatePrompt extends StatelessWidget {
  const EmptyStatePrompt({
    required this.icon,
    required this.title,
    required this.description,
    this.bannerText,
    this.bannerColor,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? bannerText;
  final Color? bannerColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badgeColor = bannerColor ?? AppColors.brandAccentText;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.primary),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              title,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              description,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (bannerText != null) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  bannerText!,
                  style: textTheme.bodyMedium?.copyWith(color: badgeColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spaceLg),
              PrimaryActionButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
