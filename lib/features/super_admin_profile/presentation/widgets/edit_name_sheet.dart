import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/widgets/edit_name_sheet_body.dart';
import 'package:mycampus/features/super_admin_profile/presentation/cubit/super_admin_profile_cubit.dart';

/// Opens the edit-display-name sheet, sharing the page's
/// [SuperAdminProfileCubit] so the sheet holds no state of its own. The
/// visual itself is the shared [EditNameSheetBody] — the student/faculty
/// profile features open the same widget from their own cubits.
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

    return BlocConsumer<SuperAdminProfileCubit, SuperAdminProfileState>(
      listenWhen: (previous, current) => previous.outcome != current.outcome,
      listener: (context, state) {
        if (state.outcome == ProfileOutcome.nameSaved) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) => EditNameSheetBody(
        formKey: cubit.nameFormKey,
        value: state.nameDraft,
        isSaving: state.isSavingName,
        errorMessage: state.outcome == ProfileOutcome.nameSaveFailed
            ? state.errorMessage
            : null,
        onChanged: cubit.nameDraftChanged,
        onSave: cubit.saveName,
      ),
    );
  }
}
