import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/super_admin_profile/presentation/cubit/super_admin_profile_cubit.dart';

/// Opens the edit-display-name sheet, sharing the page's
/// [SuperAdminProfileCubit] so the sheet holds no state of its own.
Future<void> showEditNameSheet(BuildContext context) {
  final cubit = context.read<SuperAdminProfileCubit>()..startEditingName();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _EditNameSheet()),
  );
}

class _EditNameSheet extends StatelessWidget {
  const _EditNameSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperAdminProfileCubit>();
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<SuperAdminProfileCubit, SuperAdminProfileState>(
      listenWhen: (previous, current) => previous.outcome != current.outcome,
      listener: (context, state) {
        if (state.outcome == ProfileOutcome.nameSaved) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spaceLg,
            0,
            AppTheme.spaceLg,
            MediaQuery.viewInsetsOf(context).bottom + AppTheme.spaceLg,
          ),
          child: Form(
            key: cubit.nameFormKey,
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
                  initialValue: state.nameDraft,
                  onChanged: cubit.nameDraftChanged,
                  validator: Validators.required,
                ),
                if (state.outcome == ProfileOutcome.nameSaveFailed &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    state.errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceLg),
                PrimaryActionButton(
                  label: 'common.save'.tr(),
                  isLoading: state.isSavingName,
                  onPressed: cubit.saveName,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
