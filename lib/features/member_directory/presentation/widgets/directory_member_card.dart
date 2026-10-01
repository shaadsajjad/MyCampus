import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/member_directory/domain/entities/directory_member.dart';

/// One member in the super admin's directory. Read-only by design — there
/// are no actions on a directory row, so everything a super admin needs to
/// identify someone (name, role id, email, department, batch/designation) is
/// on the card itself rather than behind a tap.
class DirectoryMemberCard extends StatelessWidget {
  const new({required this.member, super.key});

  final DirectoryMember member;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isStudent = member.role == DirectoryRole.student;

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
          // Email gets its own row rather than sitting next to the role
          // badge — it's the field an admin most often needs to read off
          // the screen, and truncating it defeats the point.
          Row(
            children: [
              Icon(Icons.alternate_email, size: 14, color: colorScheme.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  member.email,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (member.department != null || member.subInfo != null) ...[
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
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    _joinedOn(member.joinedAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// `YYYY-MM-DD` — PocketBase hands back an ISO-8601 UTC string, and the
  /// join date is a calendar day rather than a moment, so a date-only
  /// render is both simpler and less likely to look wrong to a local user
  /// than a time in UTC.
  String _joinedOn(DateTime joinedAt) {
    final local = joinedAt.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

class _RoleBadge extends StatelessWidget {
  const new({required this.role});

  final DirectoryRole role;

  @override
  Widget build(BuildContext context) {
    final isStudent = role == DirectoryRole.student;
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
