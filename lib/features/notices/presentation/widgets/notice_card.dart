import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';

class NoticeCard extends StatelessWidget {
  const new({
    required this.notice,
    this.canDelete = false,
    this.isDeleting = false,
    this.onDelete,
    super.key,
  });

  final Notice notice;

  /// Only the author (a super admin) sees the delete affordance — a
  /// student/faculty viewer leaves this false and gets a plain read-only
  /// card.
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final authorName = notice.authorName.isEmpty
        ? 'notices.unknownAuthor'.tr()
        : notice.authorName;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: colorScheme.outline),
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
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              _AudienceBadge(audience: notice.audience),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            notice.body,
            style: textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Divider(height: 1, color: colorScheme.outline),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              _AuthorAvatar(name: authorName),
              const SizedBox(width: AppTheme.spaceXs),
              Expanded(
                child: Text(
                  authorName,
                  style: textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _relativeTime(notice.createdAt),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
  const new({required this.audience});

  final NoticeAudience audience;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (audience) {
      NoticeAudience.all => (
        'notices.audienceAll'.tr(),
        Icons.public,
        AppColors.primary,
      ),
      NoticeAudience.students => (
        'roles.student'.tr(),
        Icons.school_outlined,
        AppColors.secondary,
      ),
      NoticeAudience.faculty => (
        'roles.faculty'.tr(),
        Icons.badge_outlined,
        AppColors.tertiary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// A small circular initial avatar standing in for the author's photo.
class _AuthorAvatar extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return CircleAvatar(
      radius: 10,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
