import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Compact 3-stat strip — Enrolled students, Attendance rate, Pending
/// submissions. Mirrors the Stitch mock's "Academic Telemetry" row.
class AcademicTelemetryRow extends StatelessWidget {
  const new({
    required this.enrolledCount,
    required this.sectionsCount,
    required this.attendancePercent,
    required this.attendanceDelta,
    required this.pendingSubmissions,
    super.key,
  });

  final int enrolledCount;
  final int sectionsCount;
  final double attendancePercent;
  final String attendanceDelta;
  final int pendingSubmissions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'teacher.academicTelemetry'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'teacher.activeTerm'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'teacher.enrolled'.tr(),
                value: '$enrolledCount',
                valueColor: AppColors.primary,
                footer: 'teacher.sections'
                    .tr(namedArgs: {'count': '$sectionsCount'}),
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _StatTile(
                label: 'teacher.attendanceRate'.tr(),
                value: '${attendancePercent.toStringAsFixed(1)}%',
                footer: 'teacher.trendUp'.tr(namedArgs: {'pct': attendanceDelta}),
                footerIcon: Icons.trending_up,
                footerColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _StatTile(
                label: 'teacher.submissions'.tr(),
                value: '$pendingSubmissions',
                valueColor: AppColors.tertiaryContainer,
                footer: 'teacher.needReview'.tr(),
                footerColor: AppColors.tertiary,
                showDot: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.footer,
    this.valueColor,
    this.footerColor,
    this.footerIcon,
    this.showDot = false,
  });

  final String label;
  final String value;
  final String footer;
  final Color? valueColor;
  final Color? footerColor;
  final IconData? footerIcon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.shadowSm,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMd - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor ?? AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showDot) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (footerIcon != null)
            Row(
              children: [
                Icon(footerIcon, size: 12, color: footerColor),
                const SizedBox(width: 2),
                Text(
                  footer,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: footerColor ?? AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            )
          else
            Text(
              footer,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: footerColor ?? AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
