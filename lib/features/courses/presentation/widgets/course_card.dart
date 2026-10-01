import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/courses/domain/entities/course.dart';

/// One course in the super admin's catalogue. Shows the two numbers that
/// matter to them — credits and contact hours — side by side, since
/// comparing courses is the reason this screen exists.
class CourseCard extends StatelessWidget {
  const new({
    required this.course,
    required this.isBusy,
    required this.onDelete,
    super.key,
  });

  final Course course;
  final bool isBusy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              course.code.split('-').first,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.brandAccentText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  course.title,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.workspace_premium,
                      label: 'courses.creditsShort'.tr(
                        namedArgs: {'count': '${course.credits}'},
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    _StatChip(
                      icon: Icons.schedule,
                      label: 'courses.contactHoursShort'.tr(
                        namedArgs: {'count': '${course.contactHours}'},
                      ),
                    ),
                  ],
                ),
                if (course.department != null) ...[
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    course.department!,
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'common.delete'.tr(),
            onPressed: isBusy ? null : onDelete,
            icon: isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.outline),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
