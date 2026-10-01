import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_type.dart';

/// Top-of-dashboard summary: which university this admin owns, and a
/// quick-glance badge row (active status + campus id).
class UniversityHeaderCard extends StatelessWidget {
  const new({required this.university, required this.fallbackName, super.key});

  final University? university;

  /// Shown in place of the university name while it's still loading (or
  /// failed to load) — the admin's own name/email, so the card isn't blank.
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final location = [
      university?.city,
      university?.country,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university?.name ?? fallbackName,
                      style: textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.isNotEmpty)
                      Text(
                        location,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (university?.type != null) _TypeChip(type: university!.type!),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            children: [
              _Badge(
                icon: Icons.verified,
                label: 'admin.superAdminActive'.tr(),
                background: AppColors.error.withValues(alpha: 0.12),
                foreground: AppColors.error,
              ),
              if (university != null)
                _Badge(
                  icon: Icons.tag,
                  label: '${'admin.campusId'.tr()}: ${university!.id}',
                  background: colorScheme.surfaceContainerHighest,
                  foreground: colorScheme.onSurface,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const new({required this.type});

  final UniversityType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            type.labelKey.tr(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
