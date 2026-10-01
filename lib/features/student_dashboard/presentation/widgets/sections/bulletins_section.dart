import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// "Priority University Bulletins & Notices" section — two rich cards
/// with category pill, time, title, body and (for the first one) a CTA
/// to download the hall ticket. Mirrors the bulletins block of the
/// Stitch mock; values are static until the notices feature ships.
class BulletinsSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'student.officialBulletins'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'student.viewAll'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        const _BulletinCard(
          categoryKey: 'student.examBoard',
          categoryColor: AppColors.tertiaryFixed,
          categoryTextColor: AppColors.onTertiaryFixed,
          timeText: '2 hrs ago',
          title: 'Mid-Term Examination Schedule & Hall Tickets Published',
          body:
              'Spring 2025 examination clearance slips and seat allocations '
              'are now ready for download. Please ensure fees are fully '
              'cleared.',
          primaryActionIcon: Icons.download,
          primaryActionLabelKey: 'student.downloadHallTicket',
        ),
        const SizedBox(height: AppTheme.spaceSm),
        const _BulletinCard(
          categoryKey: 'Library Admin',
          categoryColor: AppColors.surfaceContainerHigh,
          categoryTextColor: AppColors.primary,
          timeText: 'Yesterday',
          title: '24/7 Silent Study Wings Open for Finals Preparation',
          body:
              'Turing and Lovelace wings will remain unlocked continuously '
              'with complimentary refreshments from 11 PM to 4 AM.',
        ),
      ],
    );
  }
}

class _BulletinCard extends StatelessWidget {
  const new({
    required this.categoryKey,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.timeText,
    required this.title,
    required this.body,
    this.primaryActionIcon,
    this.primaryActionLabelKey,
  }) : categoryUppercase = true;

  final String categoryKey;
  final Color categoryColor;
  final Color categoryTextColor;
  final bool categoryUppercase;
  final String timeText;
  final String title;
  final String body;
  final IconData? primaryActionIcon;
  final String? primaryActionLabelKey;

  @override
  Widget build(BuildContext context) {
    final label = categoryUppercase ? categoryKey.toUpperCase() : categoryKey;
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: categoryTextColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (primaryActionIcon != null && primaryActionLabelKey != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      primaryActionIcon,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      primaryActionLabelKey!.tr(),
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.bookmark_border,
                  color: AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}