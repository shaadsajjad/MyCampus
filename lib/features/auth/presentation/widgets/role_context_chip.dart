import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// A small pill showing which role a login/register screen is for.
class RoleContextChip extends StatelessWidget {
  const RoleContextChip({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(role), size: 16, color: AppColors.brandAccentText),
          const SizedBox(width: AppTheme.spaceXs),
          Text(
            role.labelKey.tr(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.brandAccentText,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.account_balance;
      case UserRole.faculty:
        return Icons.co_present;
      case UserRole.student:
        return Icons.school;
    }
  }
}
