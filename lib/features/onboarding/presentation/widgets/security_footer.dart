import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

class SecurityFooter extends StatelessWidget {
  const SecurityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: AppTheme.spaceXs),
            Text(
              'splash.encryptedSecurity'.tr(),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          'splash.ssoProtection'.tr(),
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.outlineVariant,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
