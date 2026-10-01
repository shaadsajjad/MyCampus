import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/join_university/presentation/cubit/join_university_cubit.dart';
import 'package:mycampus/features/join_university/presentation/widgets/join_preview_card.dart';
import 'package:mycampus/features/join_university/presentation/widgets/scan_frame_overlay.dart';

/// Full-screen "scan campus QR" flow, pushed from a student/teacher
/// dashboard while they aren't yet a member of any university. Pops with
/// `true` once a join request has been sent, so the caller knows to reload
/// its own status.
class ScanJoinPage extends StatelessWidget {
  const ScanJoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinUniversityCubit(),
      child: const _ScanJoinView(),
    );
  }
}

class _ScanJoinView extends StatelessWidget {
  const _ScanJoinView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JoinUniversityCubit>();

    return Scaffold(
      appBar: AppBar(title: Text('joinUniversity.title'.tr())),
      body: BlocConsumer<JoinUniversityCubit, JoinUniversityState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case JoinUniversityStatus.failure:
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'common.error'.tr()),
                    backgroundColor: AppColors.error,
                  ),
                );
            case JoinUniversityStatus.success:
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('joinUniversity.requestSent'.tr())),
                );
              Navigator.of(context).pop(true);
            case JoinUniversityStatus.scanning:
            case JoinUniversityStatus.lookingUp:
            case JoinUniversityStatus.previewReady:
            case JoinUniversityStatus.submitting:
              break;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: cubit.scannerController,
                      onDetect: (capture) {
                        if (capture.barcodes.isEmpty) return;
                        final code = capture.barcodes.first.rawValue;
                        if (code != null) unawaited(cubit.lookupCode(code));
                      },
                      errorBuilder: (context, error) =>
                          _CameraUnavailable(error: error),
                    ),
                    const ScanFrameOverlay(),
                    Positioned(
                      left: AppTheme.spaceLg,
                      right: AppTheme.spaceLg,
                      bottom: AppTheme.spaceLg,
                      child: Text(
                        'joinUniversity.scanInstructions'.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    if (state.status == JoinUniversityStatus.lookingUp)
                      const ColoredBox(
                        color: Colors.black54,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: state.preview != null
                      ? JoinPreviewCard(
                          preview: state.preview!,
                          isSubmitting:
                              state.status == JoinUniversityStatus.submitting,
                          onConfirm: cubit.confirmJoin,
                          onCancel: cubit.resumeScanning,
                        )
                      : _ManualEntry(
                          value: state.manualCode,
                          onChanged: cubit.updateManualCode,
                          onSubmit: cubit.submitManualCode,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  const _ManualEntry({
    required this.value,
    required this.onChanged,
    required this.onSubmit,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'joinUniversity.manualEntryLabel'.tr(),
          icon: Icons.qr_code,
          initialValue: value,
          onChanged: onChanged,
          isRequired: false,
          hint: 'joinUniversity.manualEntryHint'.tr(),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        PrimaryActionButton(
          label: 'joinUniversity.lookUp'.tr(),
          onPressed: value.trim().isEmpty ? null : onSubmit,
        ),
      ],
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                'joinUniversity.cameraPermissionTitle'.tr(),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'joinUniversity.cameraPermissionDesc'.tr(),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
