import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/onboarding/domain/entities/auth_mode.dart';

class AuthToggle extends StatelessWidget {
  const AuthToggle({
    required this.currentMode,
    required this.onToggle,
    super.key,
  });

  final AuthMode currentMode;
  final ValueChanged<AuthMode> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          currentMode == AuthMode.login
              ? 'splash.alreadyRegistered'.tr()
              : 'splash.joiningFirstTime'.tr(),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(context, 'common.login'.tr(), AuthMode.login),
              _buildTab(
                context,
                'splash.newEnrollment'.tr(),
                AuthMode.register,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, AuthMode mode) {
    final isSelected = currentMode == mode;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => onToggle(mode),
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg,
          vertical: AppTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceCard : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: isSelected ? AppColors.shadowSm : null,
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppColors.onSurface
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
