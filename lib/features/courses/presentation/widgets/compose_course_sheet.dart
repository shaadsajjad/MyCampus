import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/courses/presentation/cubit/compose_course_cubit.dart';

/// Bottom sheet for defining a new course. Resolves to `true` on success so
/// the caller knows to reload the list — the same contract
/// `ComposeNoticeSheet` uses, and the reason the two Cubits never have to
/// know about each other.
class ComposeCourseSheet extends StatelessWidget {
  const ComposeCourseSheet({super.key});

  /// Shows the sheet and resolves to `true` when a course was created.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => ComposeCourseCubit(),
        child: const ComposeCourseSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComposeCourseCubit>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ComposeCourseCubit, ComposeCourseState>(
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
          // Lifts the sheet above the keyboard so the credit/contact-hour
          // fields stay visible while typing.
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
                      'courses.newCourse'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      'courses.newCourseDesc'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    AppTextField(
                      label: 'courses.courseCode'.tr(),
                      icon: Icons.tag,
                      initialValue: state.code,
                      onChanged: cubit.codeChanged,
                      hint: 'CSE-101',
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    AppTextField(
                      label: 'courses.courseTitle'.tr(),
                      icon: Icons.menu_book,
                      initialValue: state.title,
                      onChanged: cubit.titleChanged,
                      hint: 'Introduction to Programming',
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'courses.credits'.tr(),
                            icon: Icons.workspace_premium,
                            initialValue: state.credits,
                            onChanged: cubit.creditsChanged,
                            keyboardType: TextInputType.number,
                            validator: cubit.positiveIntValidator(),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: AppTextField(
                            label: 'courses.contactHours'.tr(),
                            icon: Icons.schedule,
                            initialValue: state.contactHours,
                            onChanged: cubit.contactHoursChanged,
                            keyboardType: TextInputType.number,
                            validator: cubit.positiveIntValidator(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    AppTextField(
                      label: 'common.department'.tr(),
                      icon: Icons.apartment,
                      initialValue: state.department,
                      onChanged: cubit.departmentChanged,
                      isRequired: false,
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                    PrimaryActionButton(
                      label: 'courses.saveCourse'.tr(),
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
