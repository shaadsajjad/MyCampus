import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/presentation/cubit/compose_notice_cubit.dart';

/// Opens the "new notice" sheet with its own, fresh [ComposeNoticeCubit].
/// Resolves to `true` if a notice was actually created, so the caller
/// knows to reload its list.
Future<bool?> showComposeNoticeSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider(
      create: (_) => ComposeNoticeCubit(),
      child: const _ComposeNoticeSheet(),
    ),
  );
}

class _ComposeNoticeSheet extends StatelessWidget {
  const _ComposeNoticeSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComposeNoticeCubit>();
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<ComposeNoticeCubit, ComposeNoticeState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spaceLg,
            right: AppTheme.spaceLg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppTheme.spaceLg,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: cubit.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('notices.newNotice'.tr(), style: textTheme.titleLarge),
                  const SizedBox(height: AppTheme.spaceLg),
                  AppTextField(
                    label: 'notices.title'.tr(),
                    icon: Icons.title,
                    hint: 'notices.titleHint'.tr(),
                    initialValue: state.title,
                    onChanged: cubit.titleChanged,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  _BodyField(value: state.body, onChanged: cubit.bodyChanged),
                  const SizedBox(height: AppTheme.spaceMd),
                  _AudiencePicker(
                    value: state.audience,
                    onChanged: cubit.audienceChanged,
                  ),
                  if (state.status == SubmissionStatus.failure &&
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
                    label: 'notices.post'.tr(),
                    isLoading: state.status == SubmissionStatus.submitting,
                    onPressed: cubit.submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BodyField extends StatelessWidget {
  const _BodyField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notices.body'.tr(),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.spaceXs),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          minLines: 3,
          maxLines: 6,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.required,
          decoration: InputDecoration(hintText: 'notices.bodyHint'.tr()),
        ),
      ],
    );
  }
}

class _AudiencePicker extends StatelessWidget {
  const _AudiencePicker({required this.value, required this.onChanged});

  final NoticeAudience value;
  final ValueChanged<NoticeAudience> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notices.audience'.tr(),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.spaceXs),
        SegmentedButton<NoticeAudience>(
          segments: [
            ButtonSegment(
              value: NoticeAudience.all,
              label: Text('notices.audienceAll'.tr()),
            ),
            ButtonSegment(
              value: NoticeAudience.students,
              label: Text('roles.student'.tr()),
            ),
            ButtonSegment(
              value: NoticeAudience.faculty,
              label: Text('roles.faculty'.tr()),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
