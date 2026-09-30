import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

class SecurityPolicyNote extends StatelessWidget {
  const SecurityPolicyNote({super.key});

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
            children: [
              const Icon(
                Icons.security_update_good,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                'admin.securityPolicyTitle'.tr(),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text('admin.securityPolicyDesc'.tr(), style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
