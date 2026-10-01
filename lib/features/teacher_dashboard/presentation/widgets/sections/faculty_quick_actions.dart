import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Faculty Quick Actions 2x2 bento — Mark Attendance, Post Notice,
/// Gradebook, Course Materials. Each tile has its own accent color,
/// icon, title and short helper line.
class FacultyQuickActions extends StatelessWidget {
  const FacultyQuickActions({
    required this.onMarkAttendanceTap,
    required this.onPostNoticeTap,
    required this.onGradebookTap,
    required this.onMaterialsTap,
    super.key,
  });

  final VoidCallback onMarkAttendanceTap;
  final VoidCallback onPostNoticeTap;
  final VoidCallback onGradebookTap;
  final VoidCallback onMaterialsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'teacher.facultyQuickActions'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'teacher.dailyTools'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _ActionTile(
              icon: Icons.qr_code_scanner,
              iconBg: AppColors.secondaryFixed,
              iconColor: AppColors.primary,
              title: 'teacher.markAttendance'.tr(),
              subtitle: 'teacher.liveScanner'.tr(),
              onTap: onMarkAttendanceTap,
            ),
            _ActionTile(
              icon: Icons.campaign,
              iconBg: AppColors.surfaceVariant,
              iconColor: AppColors.onPrimaryFixedVariant,
              title: 'teacher.postNotice'.tr(),
              subtitle: 'teacher.urgentBulletin'.tr(),
              onTap: onPostNoticeTap,
            ),
            _ActionTile(
              icon: Icons.fact_check,
              iconBg: AppColors.tertiaryFixed,
              iconColor: AppColors.onTertiaryFixed,
              title: 'teacher.uploadResults'.tr(),
              subtitle: 'teacher.assessments'.tr(),
              onTap: onGradebookTap,
            ),
            _ActionTile(
              icon: Icons.folder_open,
              iconBg: AppColors.surfaceContainerHigh,
              iconColor: AppColors.primary,
              title: 'teacher.courseMaterials'.tr(),
              subtitle: 'teacher.slidesPdf'.tr(),
              onTap: onMaterialsTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.all(AppTheme.spaceMd - 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd + 2),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: iconColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
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