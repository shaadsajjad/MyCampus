import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/app_dropdown_field.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/routine/presentation/cubit/compose_routine_slot_cubit.dart';
import 'package:mycampus/features/routine/presentation/widgets/app_time_field.dart';

/// Bottom sheet for adding a slot to the weekly timetable. Resolves to
/// `true` on success — same `ComposeCourseSheet`/`ComposeNoticeSheet`
/// contract.
class ComposeRoutineSlotSheet extends StatelessWidget {
  const new({super.key});

  /// Shows the sheet and resolves to `true` when a slot was created.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => ComposeRoutineSlotCubit(),
        child: const ComposeRoutineSlotSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComposeRoutineSlotCubit>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ComposeRoutineSlotCubit, ComposeRoutineSlotState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SubmissionStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == SubmissionStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage ?? '')));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'routine.newSlot'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      'routine.newSlotDesc'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    if (state.isLoadingCourses)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spaceLg,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.courseOptions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spaceSm,
                        ),
                        child: Text(
                          'routine.noCoursesYet'.tr(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      AppDropdownField<String>(
                        label: 'routine.course'.tr(),
                        icon: Icons.menu_book,
                        value: state.courseId,
                        items: [
                          for (final option in state.courseOptions) option.id,
                        ],
                        itemLabel: (id) {
                          final option = state.courseOptions.firstWhere(
                            (o) => o.id == id,
                          );
                          return '${option.code} — ${option.title}';
                        },
                        onChanged: cubit.courseChanged,
                      ),
                    const SizedBox(height: AppTheme.spaceMd),
                    AppDropdownField<DayOfWeek>(
                      label: 'routine.day'.tr(),
                      icon: Icons.calendar_today,
                      value: state.day,
                      items: DayOfWeek.values,
                      itemLabel: (day) => day.labelKey.tr(),
                      onChanged: cubit.dayChanged,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTimeField(
                            label: 'routine.startTime'.tr(),
                            icon: Icons.schedule,
                            value: state.startTime,
                            onChanged: cubit.startTimeChanged,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: AppTimeField(
                            label: 'routine.endTime'.tr(),
                            icon: Icons.schedule,
                            value: state.endTime,
                            onChanged: cubit.endTimeChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    AppTextField(
                      label: 'routine.room'.tr(),
                      icon: Icons.meeting_room_outlined,
                      initialValue: state.room,
                      onChanged: cubit.roomChanged,
                      isRequired: false,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    AppTextField(
                      label: 'routine.section'.tr(),
                      icon: Icons.groups_outlined,
                      initialValue: state.section,
                      onChanged: cubit.sectionChanged,
                      isRequired: false,
                    ),
                    // Shown inline (not just the SnackBar from the
                    // listener above) — a SnackBar is easy to miss inside
                    // a modal sheet, and the most common failure here
                    // (end time before start time) needs to stay visible
                    // until the user actually fixes it.
                    if (state.status == SubmissionStatus.failure &&
                        state.errorMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spaceSm,
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spaceLg),
                    PrimaryActionButton(
                      label: 'routine.saveSlot'.tr(),
                      isLoading: state.status == SubmissionStatus.submitting,
                      onPressed: cubit.submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
