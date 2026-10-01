import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// 2x2 bento grid of academic shortcuts: Routine, Check-In, Gradebook,
/// Campus Services. Each tile has its own accent + small badge. Mirrors
/// the "Academic Tools" section of the Stitch mock.
class AcademicToolsBento extends StatelessWidget {
  const new({
    required this.onRoutineTap,
    required this.onCheckInTap,
    required this.onResultsTap,
    required this.onServicesTap,
    super.key,
  });

  final VoidCallback onRoutineTap;
  final VoidCallback onCheckInTap;
  final VoidCallback onResultsTap;
  final VoidCallback onServicesTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'student.academicTools'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'student.quickAccess'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _BentoTile(
              icon: Icons.calendar_month,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.primary,
              title: 'student.routine'.tr(),
              subtitle: 'Turing Hall, Block 4',
              badgeText: 'student.todayCount'.tr(namedArgs: {'count': '3'}),
              badgeColor: AppColors.surfaceContainerHigh,
              badgeTextColor: AppColors.primary,
              onTap: onRoutineTap,
            ),
            _BentoTile(
              icon: Icons.how_to_reg,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.secondary,
              title: 'student.checkIn'.tr(),
              subtitle: 'student.autoBeacon'.tr(),
              badgeText: 'student.geofenceOk'.tr(),
              badgeColor: AppColors.secondaryFixed,
              badgeTextColor: AppColors.onSecondaryFixed,
              onTap: onCheckInTap,
            ),
            _BentoTile(
              icon: Icons.stars,
              iconBg: AppColors.surfaceContainerHigh,
              iconColor: AppColors.onSurface,
              iconFill: 1,
              titlePrefix: TextSpan(
                text: '3.86 ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titleSuffix: TextSpan(
                text: 'student.cgpaLabel'.tr(),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              subtitle: 'student.deanList'.tr(),
              badgeText: 'student.topPercent'.tr(namedArgs: {'pct': '3'}),
              badgeColor: AppColors.tertiaryFixed,
              badgeTextColor: AppColors.onTertiaryFixed,
              onTap: onResultsTap,
            ),
            _BentoTile(
              icon: Icons.devices,
              iconBg: AppColors.surfaceContainerLow,
              iconColor: AppColors.primary,
              title: 'student.campusServices'.tr(),
              subtitle: 'student.libDining'.tr(),
              badgeText: 'student.services'.tr(),
              badgeColor: AppColors.surfaceContainer,
              badgeTextColor: AppColors.onSurface,
              onTap: onServicesTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
    this.title,
    this.iconFill,
    this.titlePrefix,
    this.titleSuffix,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? title;
  final InlineSpan? titlePrefix;
  final InlineSpan? titleSuffix;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;
  final double? iconFill;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppColors.shadowSm,
          ),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 22,
                      fill: iconFill,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      badgeText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (titlePrefix != null || titleSuffix != null)
                    RichText(
                      text: TextSpan(children: [?titlePrefix, ?titleSuffix]),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
