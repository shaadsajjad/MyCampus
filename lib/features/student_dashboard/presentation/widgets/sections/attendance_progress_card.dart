import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Circular progress meter + per-session breakdown bars for the student's
/// overall attendance. Mocked values mirror the Stitch design (92%
/// overall, 94% lectures, 89% labs) — these are the first real data the
/// attendance feature will replace once it ships.
class AttendanceProgressCard extends StatelessWidget {
  const AttendanceProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppColors.shadowSm,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'student.attendanceProgress'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'student.minRequirement'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'student.creditsActive'.tr(namedArgs: {'count': '18'}),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSecondaryFixed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              const _AttendanceRing(percent: 92),
              const SizedBox(width: AppTheme.spaceLg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _ProgressBar(label: 'Lecture Sessions', percent: 94),
                    SizedBox(height: AppTheme.spaceSm),
                    _ProgressBar(label: 'Laboratory & Practicals', percent: 89),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceRing extends StatelessWidget {
  const _AttendanceRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 3.5,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'student.overall'.tr(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.label, required this.percent});

  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final labelKey = label == 'Lecture Sessions'
        ? 'student.lectureSessions'
        : 'student.labSessions';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelKey.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}