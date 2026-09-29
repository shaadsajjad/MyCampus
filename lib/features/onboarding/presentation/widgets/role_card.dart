import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/onboarding/presentation/models/role_option.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandTint : AppColors.surfaceCard,
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
                    color: option.iconStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Icon(
                    option.iconStyle.icon,
                    color: option.iconStyle.color,
                    size: 26,
                  ),
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
                              option.titleKey.tr(),
                              style: textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (option.role == UserRole.student) ...[
                            const SizedBox(width: AppTheme.spaceXs),
                            _buildPopularBadge(textTheme),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitleKey.tr(),
                        style: textTheme.bodySmall,
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
              children: [_buildBadge(textTheme), _buildTrailing(textTheme)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBadge(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE1FF),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        'splash.mostPopular'.tr(),
        style: textTheme.labelSmall?.copyWith(
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

  Widget _buildBadge(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        color: option.badge.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: option.badge.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spaceXs),
          Text(
            option.badge.textKey.tr(),
            style: textTheme.labelSmall?.copyWith(
              color: option.badge.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(TextTheme textTheme) {
    return Text(
      option.trailingTextKey.tr(),
      style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
    );
  }
}
