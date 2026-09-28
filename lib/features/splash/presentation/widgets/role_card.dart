import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/text_styles.dart';
import '../cubit/splash_cubit.dart';

class RoleCard extends StatelessWidget {
  final UserRole role;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeTextKey;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color badgeDotColor;
  final String trailingTextKey;
  final IconData? trailingIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeTextKey,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.badgeDotColor,
    required this.trailingTextKey,
    this.trailingIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF4FF)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppColors.shadowMd : AppColors.shadowSm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              titleKey.tr(),
                              style: AppTextStyles.titleMd,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (role == UserRole.student) ...[
                            const SizedBox(width: AppTheme.spaceXs),
                            _buildPopularBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleKey.tr(),
                        style: AppTextStyles.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildRadio(),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(),
                _buildTrailing(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE1FF),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        'splash.mostPopular'.tr(),
        style: AppTextStyles.labelSm.copyWith(
          color: const Color(0xFF00174B),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildRadio() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: AppColors.onSecondary)
          : null,
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeDotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spaceXs),
          Text(
            badgeTextKey.tr(),
            style: AppTextStyles.labelSm.copyWith(color: badgeTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing() {
    return Text(
      trailingTextKey.tr(),
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.outline,
      ),
    );
  }
}
