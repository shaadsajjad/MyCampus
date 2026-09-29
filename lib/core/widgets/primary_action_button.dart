import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// A full-width primary call-to-action button with a trailing arrow — used
/// to advance a multi-step flow (onboarding, auth forms). Shared across
/// features since it's generic UI chrome, not feature-specific.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            const SizedBox(width: AppTheme.spaceSm),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
