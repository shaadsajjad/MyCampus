import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';

/// Presentational body of the "edit display name" bottom sheet, shared by
/// the super admin, student and faculty profile screens.
///
/// Deliberately dumb — plain values in, callbacks out — so `core` knows
/// nothing about any feature's cubit. Each profile feature keeps its own
/// thin `showEditNameSheet(context)` that reads its cubit and opens this,
/// which is why all three sheets stay pixel-identical without `core`
/// depending on three different cubit types.
class EditNameSheetBody extends StatelessWidget {
  const new({
    required this.formKey,
    required this.value,
    required this.isSaving,
    required this.onChanged,
    required this.onSave,
    this.errorMessage,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final String value;
  final bool isSaving;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;

  /// Non-null only right after a failed save, rendered inline above the
  /// save button.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        0,
        AppTheme.spaceLg,
        MediaQuery.viewInsetsOf(context).bottom + AppTheme.spaceLg,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('profile.editName'.tr(), style: textTheme.titleLarge),
            const SizedBox(height: AppTheme.spaceXs),
            Text('profile.editNameDesc'.tr(), style: textTheme.bodySmall),
            const SizedBox(height: AppTheme.spaceLg),
            AppTextField(
              label: 'common.name'.tr(),
              icon: Icons.person_outline,
              hint: 'common.fullNameHint'.tr(),
              initialValue: value,
              onChanged: onChanged,
              validator: Validators.required,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            PrimaryActionButton(
              label: 'common.save'.tr(),
              isLoading: isSaving,
              onPressed: onSave,
            ),
          ],
        ),
      ),
    );
  }
}
