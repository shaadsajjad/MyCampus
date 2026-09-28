import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/text_styles.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        children: [
          _buildBadge(),
          const SizedBox(height: AppTheme.spaceMd),
          _buildLogo(),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'app.name'.tr(),
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'app.tagline'.tr(),
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'splash.description'.tr(),
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppTheme.spaceXs),
          Text(
            'splash.officialBadge'.tr(),
            style: AppTextStyles.labelSm.copyWith(
              color: const Color(0xFF264191),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppColors.shadowSm,
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              size: 12,
              color: AppColors.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
