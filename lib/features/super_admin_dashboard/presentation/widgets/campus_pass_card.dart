import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/constants/app_assets.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/campus_pass.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/cubit/campus_pass_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The university's join-code QR — students/teachers scan it to request
/// access (see `admin.qrInstructions`). [campusId] is the underlying
/// `universities` record id, doubling as the join code encoded in the QR.
///
/// Save/share go through [CampusPassCubit] (provided by the page); this
/// widget only reads its busy state and dispatches, holding no state of
/// its own.
class CampusPassCard extends StatelessWidget {
  const CampusPassCard({
    required this.campusId,
    required this.universityName,
    required this.onAction,
    super.key,
  });

  final String? campusId;
  final String? universityName;
  final void Function(String message) onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final id = campusId;
    final pass = id == null || id.isEmpty
        ? null
        : CampusPass(campusId: id, universityName: universityName);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryContainer,
            Color(0xFF213145),
          ],
        ),
        boxShadow: AppColors.shadowLg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 18,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: AppTheme.spaceXs),
                  Text(
                    'admin.officialPassProtocol'.tr(),
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceXs),
                    Text(
                      'admin.liveGateway'.tr(),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _QrPanel(campusId: campusId),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            'admin.campusEnrollmentQr'.tr(),
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          if (pass != null)
            _CopyIdPill(
              campusId: pass.campusId,
              onCopied: () => onAction('admin.campusIdCopied'.tr()),
            ),
          const SizedBox(height: AppTheme.spaceLg),
          BlocBuilder<CampusPassCubit, CampusPassState>(
            builder: (context, passState) {
              final cubit = context.read<CampusPassCubit>();
              final canAct = pass != null && !passState.isBusy;
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: canAct ? () => cubit.save(pass) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.white70,
                      ),
                      icon: passState.action == CampusPassAction.saving
                          ? const _ButtonSpinner(color: AppColors.primary)
                          : const Icon(Icons.download),
                      label: Text('admin.downloadPoster'.tr()),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          // Builder so the share button's own box can be
                          // the iPad/macOS share-sheet anchor.
                          child: Builder(
                            builder: (buttonContext) => OutlinedButton.icon(
                              onPressed: canAct
                                  ? () => cubit.share(
                                      pass,
                                      message: 'admin.qrInstructions'.tr(),
                                      anchor: _anchorOf(buttonContext),
                                    )
                                  : null,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white54,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              icon: passState.action == CampusPassAction.sharing
                                  ? const _ButtonSpinner(color: Colors.white)
                                  : const Icon(Icons.share),
                              label: Text('admin.shareDigitalPass'.tr()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton.outlined(
                          onPressed: () => onAction('admin.comingSoon'.tr()),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          tooltip: 'admin.regenerateToken'.tr(),
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  ShareAnchor? _anchorOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return (
      left: origin.dx,
      top: origin.dy,
      width: box.size.width,
      height: box.size.height,
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  const _QrPanel({required this.campusId});

  final String? campusId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 216,
      height: 216,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.shadowMd,
      ),
      child: campusId == null || campusId!.isEmpty
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          : QrImageView(
              data: campusId!,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              padding: EdgeInsets.zero,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primary,
              ),
              embeddedImage: const AssetImage(AppAssets.logo),
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(36, 36),
              ),
            ),
    );
  }
}

class _CopyIdPill extends StatelessWidget {
  const _CopyIdPill({required this.campusId, required this.onCopied});

  final String campusId;
  final VoidCallback onCopied;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        onTap: () {
          unawaited(Clipboard.setData(ClipboardData(text: campusId)));
          onCopied();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                campusId,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: AppTheme.spaceXs),
              const Icon(Icons.content_copy, size: 14, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
