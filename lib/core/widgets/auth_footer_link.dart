import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';

/// A "Don't have an account? Register" style row with a tappable action.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.promptKey,
    required this.actionKey,
    required this.onTap,
    super.key,
  });

  final String promptKey;
  final String actionKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(promptKey.tr(), style: textTheme.bodyMedium),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionKey.tr(),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
