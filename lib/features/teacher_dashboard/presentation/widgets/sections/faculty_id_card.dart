import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_university.dart';

/// Approved Faculty ID & Access card — gradient background, university
/// header, profile photo + ID, lab access bar with "Show Pass" trigger.
/// Mirrors the design from the Stitch-generated mock; takes the avatar
/// URL from the `users.avatar` field when present.
class FacultyIdCard extends StatelessWidget {
  const new({
    required this.university,
    required this.facultyName,
    required this.department,
    required this.facultyId,
    this.avatarUrl,
    this.designation = 'Assistant Professor',
    this.onShowPass,
    super.key,
  });

  final TeacherUniversity? university;
  final String facultyName;
  final String department;
  final String facultyId;
  final String? avatarUrl;
  final String designation;
  final VoidCallback? onShowPass;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryContainer,
                AppColors.primary,
                Color(0xFF213145),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppColors.shadowMd,
          ),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Color(0xFFFFB77D),
                          size: 18,
                          fill: 1,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            university?.name ?? 'Campus',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primaryFixed,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSm + 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Color(0xFFFFDCC3),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'teacher.staffTier1'.tr(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFFFFDCC3),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: avatarUrl != null
                            ? Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _InitialsAvatar(name: facultyName),
                              )
                            : _InitialsAvatar(name: facultyName),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spaceMd - 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          facultyName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          department,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.surfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                              ),
                              child: Text(
                                'teacher.facultyId'.tr(
                                  namedArgs: {'id': facultyId},
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.primaryFixedDim,
                                    ),
                              ),
                            ),
                            Text(
                              'teacher.labStaffAccess'.tr(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.surfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm + 2,
                  vertical: AppTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.contactless,
                      color: AppColors.secondaryFixed,
                      size: 18,
                    ),
                    const SizedBox(width: AppTheme.spaceXs),
                    Expanded(
                      child: Text(
                        'teacher.smartTurnstile'.tr(),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.surfaceBright),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      onTap: onShowPass,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceSm + 2,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          boxShadow: AppColors.shadowSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_2,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'teacher.showPass'.tr(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    return Container(
      color: AppColors.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
