import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    required this.notice,
    required this.canDelete,
    required this.isDeleting,
    required this.onDelete,
    super.key,
  });

  final Notice notice;
  final bool canDelete;
  final bool isDeleting;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _AudienceBadge(audience: notice.audience),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(notice.body, style: textTheme.bodyMedium),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 14,
                color: colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  notice.authorName.isEmpty
                      ? 'notices.unknownAuthor'.tr()
                      : notice.authorName,
                  style: textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _relativeTime(notice.createdAt),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: AppTheme.spaceXs),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: isDeleting
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          tooltip: 'common.cancel'.tr(),
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'admin.justNow'.tr();
    if (diff.inMinutes < 60) {
      return 'admin.minutesAgo'.tr(namedArgs: {'count': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return 'admin.hoursAgo'.tr(namedArgs: {'count': '${diff.inHours}'});
    }
    return 'admin.daysAgo'.tr(namedArgs: {'count': '${diff.inDays}'});
  }
}

class _AudienceBadge extends StatelessWidget {
  const _AudienceBadge({required this.audience});

  final NoticeAudience audience;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (audience) {
      NoticeAudience.all => ('notices.audienceAll'.tr(), AppColors.primary),
      NoticeAudience.students => ('roles.student'.tr(), AppColors.secondary),
      NoticeAudience.faculty => ('roles.faculty'.tr(), AppColors.tertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
