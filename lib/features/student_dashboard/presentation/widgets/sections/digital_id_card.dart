import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_university.dart';

/// Institutional Digital ID card — gradient, university name, profile photo,
/// ID + program, NFC status and "View QR" trigger. Mirrors the design
/// from the Stitch-generated mock; accepts an optional `avatarUrl` so the
/// student's photo (from the `users.avatar` field) is used when set.
class DigitalIdCard extends StatelessWidget {
  const new({
    required this.university,
    required this.studentName,
    required this.program,
    required this.studentId,
    this.avatarUrl,
    this.honor = 'Honor Scholar',
    this.expiry = 'Jun 2026',
    this.onShowQr,
    super.key,
  });

  final StudentUniversity? university;
  final String studentName;
  final String program;
  final String studentId;
  final String? avatarUrl;
  final String honor;
  final String expiry;
  final VoidCallback? onShowQr;

  @override
  Widget build(BuildContext context) {
    final shortId = studentId.isNotEmpty
        ? (studentId.length > 8
              ? studentId.substring(0, 8).toUpperCase()
              : studentId)
        : 'STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryContainer,
                Color(0xFF213145),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl + 4),
            boxShadow: AppColors.shadowLg,
          ),
          padding: const EdgeInsets.all(AppTheme.spaceMd + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFFFFDCC3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                university?.name ?? 'Campus',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'student.officialStudentSmartPass'.tr(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.primaryFixedDim,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      'STU-$shortId',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: Colors.white, letterSpacing: 0.4),
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
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: avatarUrl != null
                            ? Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _InitialsAvatar(name: studentName),
                              )
                            : _InitialsAvatar(name: studentName),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          studentName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          program,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.primaryFixedDim),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'student.expiresLabel'.tr(
                                namedArgs: {'date': expiry},
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.primaryFixedDim),
                            ),
                            const Text(
                              '•',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              honor,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFFFFDCC3),
                                    fontWeight: FontWeight.w600,
                                  ),
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
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sensors,
                      size: 18,
                      color: AppColors.primaryFixedDim,
                    ),
                    const SizedBox(width: AppTheme.spaceXs),
                    Expanded(
                      child: Text(
                        'student.nfcReady'.tr(),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.primaryFixedDim),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      onTap: onShowQr,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceSm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'student.viewQr'.tr(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
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
        // Top decorative foil strip
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFDCC3),
                  Color(0xFFFC922B),
                  AppColors.secondaryFixed,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusXl + 4),
                topRight: Radius.circular(AppTheme.radiusXl + 4),
              ),
            ),
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
    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
