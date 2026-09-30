import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/university_stats.dart';

/// The three at-a-glance counts on the dashboard: pending join requests,
/// approved students, approved faculty. [stats] is null while loading or
/// if the fetch failed — each tile then shows a placeholder dash.
class AccessMetricsRow extends StatelessWidget {
  const AccessMetricsRow({required this.stats, super.key});

  final UniversityStats? stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'admin.accessMetrics'.tr(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('admin.realtimeSync'.tr(), style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.qr_code_2,
                iconColor: AppColors.tertiary,
                value: stats?.pendingRequests,
                label: 'admin.pending'.tr(),
                tag: (stats?.pendingRequests ?? 0) > 0
                    ? 'admin.actionRequired'.tr()
                    : null,
                tagColor: AppColors.tertiary,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _MetricTile(
                icon: Icons.school,
                iconColor: AppColors.secondary,
                value: stats?.approvedStudents,
                label: 'admin.students'.tr(),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _MetricTile(
                icon: Icons.groups,
                iconColor: AppColors.primary,
                value: stats?.approvedFaculty,
                label: 'admin.faculty'.tr(),
                tag: 'admin.fullRoster'.tr(),
                tagColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.tag,
    this.tagColor,
  });

  final IconData icon;
  final Color iconColor;
  final int? value;
  final String label;
  final String? tag;
  final Color? tagColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            value == null ? 'admin.statsUnavailable'.tr() : '$value',
            style: textTheme.headlineMedium,
          ),
          Text(
            label,
            style: textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (tag != null) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (tagColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                tag!,
                style: textTheme.labelSmall?.copyWith(
                  color: tagColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
