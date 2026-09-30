import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/join_requests/domain/entities/member_request.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    required this.member,
    required this.isSelected,
    required this.isBusy,
    required this.onToggleSelected,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final MemberRequest member;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onToggleSelected;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isStudent = member.role == MemberRole.student;
    final isPending = member.status == MemberStatus.pending;

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
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppTheme.spaceSm,
                    top: 2,
                  ),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelected(),
                  ),
                ),
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Icon(
                        isStudent ? Icons.school : Icons.co_present,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.roleId != null)
                      Text(member.roleId!, style: textTheme.bodySmall),
                  ],
                ),
              ),
              _RoleBadge(role: member.role),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSm,
              vertical: AppTheme.spaceXs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    [
                      member.department,
                      member.subInfo,
                    ].whereType<String>().join(' • '),
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _relativeTime(member.requestedAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: isBusy ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.outline),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text('common.reject'.tr()),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: isBusy ? null : onApprove,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.check_circle, size: 18),
                      label: Text('admin.approveAccess'.tr()),
                    ),
                  ),
                ),
              ],
            )
          else
            _StatusPill(status: member.status),
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final MemberRole role;

  @override
  Widget build(BuildContext context) {
    final isStudent = role == MemberRole.student;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isStudent
            ? colorScheme.surfaceContainerHigh
            : AppColors.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStudent ? Icons.school : Icons.badge,
            size: 13,
            color: isStudent ? AppColors.primary : AppColors.tertiary,
          ),
          const SizedBox(width: 4),
          Text(
            (isStudent ? 'roles.student' : 'roles.faculty').tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isStudent ? AppColors.primary : AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    final approved = status == MemberStatus.approved;
    final color = approved ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            approved ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            (approved ? 'status.approved' : 'status.rejected').tr(),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
