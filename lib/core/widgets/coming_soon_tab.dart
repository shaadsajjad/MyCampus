import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Generic placeholder shown for Routine / Notices / Profile tabs in the
/// redesigned dashboards — keeps the nav shell honest while the
/// feature work behind those tabs is still pending. Each tab passes its
/// own `titleKey` and `icon`.
class ComingSoonTab extends StatelessWidget {
  const ComingSoonTab({required this.titleKey, required this.icon, super.key});

  final String titleKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            titleKey.tr(),
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'common.comingSoon'.tr(),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}