import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university.dart' show University;

/// Pill-shaped status bar shown at the top of the approved student
/// dashboard — "Access Granted • [University] Active" plus a
/// "Campus Pass" action. Pure presentational widget, mirrors the design
/// from the Stitch-generated mock.
class AccessPillBar extends StatelessWidget {
  const new({required this.universityName, super.key});

  final String universityName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.shadowSm,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              color: AppColors.secondary,
              size: 18,
              fill: 1,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'student.accessGranted'.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceXs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceXs),
                    Flexible(
                      child: Text(
                        'student.accessGrantedSubtitle'.tr(
                          namedArgs: {'university': universityName},
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  'student.campusPassTerm'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          _PassButton(onTap: () {}),
        ],
      ),
    );
  }
}

class _PassButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.contactless,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'student.campusPass'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}