import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Purely decorative square viewfinder drawn over the live camera preview.
class ScanFrameOverlay extends StatelessWidget {
  const ScanFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.65,
          heightFactor: 0.35,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.onPrimaryContainer, width: 3),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
