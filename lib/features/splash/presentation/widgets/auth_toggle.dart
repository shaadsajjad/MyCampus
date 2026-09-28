import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/text_styles.dart';
import '../cubit/splash_cubit.dart';

class AuthToggle extends StatelessWidget {
  final AuthMode currentMode;
  final Function(AuthMode) onToggle;

  const AuthToggle({
    super.key,
    required this.currentMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          currentMode == AuthMode.login
              ? 'splash.alreadyRegistered'.tr()
              : 'splash.joiningFirstTime'.tr(),
          style: AppTextStyles.bodySm,
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
              _buildTab('common.login'.tr(), AuthMode.login),
              _buildTab('splash.newEnrollment'.tr(), AuthMode.register),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, AuthMode mode) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onToggle(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
