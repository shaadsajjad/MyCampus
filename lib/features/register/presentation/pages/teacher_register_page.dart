import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_image_picker_field.dart';
import 'package:mycampus/core/widgets/app_password_field.dart';
import 'package:mycampus/core/widgets/app_text_field.dart';
import 'package:mycampus/core/widgets/auth_footer_link.dart';
import 'package:mycampus/core/widgets/auth_scaffold.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/core/widgets/role_context_chip.dart';
import 'package:mycampus/features/register/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/register/presentation/cubit/teacher_register_cubit.dart';
import 'package:mycampus/features/register/presentation/submission_status.dart';
import 'package:mycampus/features/register/presentation/widgets/app_dropdown_field.dart';
import 'package:mycampus/features/register/presentation/widgets/department_options.dart';
import 'package:mycampus/features/register/presentation/widgets/form_section_card.dart';

class TeacherRegisterPage extends StatelessWidget {
  const TeacherRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherRegisterCubit(),
      child: const TeacherRegisterView(),
    );
  }
}

class TeacherRegisterView extends StatelessWidget {
  const TeacherRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TeacherRegisterCubit>();

    return AuthScaffold(
      title: 'register.registerTitle'.tr(),
      subtitle: 'register.registerSubtitle'.tr(),
      child: BlocListener<TeacherRegisterCubit, TeacherRegisterState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == SubmissionStatus.success) {
            // Navigate to verification page with the registered email
            context.go(
              AppRoute.verificationPath(state.email),
              extra: state.password,
            );
          } else if (state.status == SubmissionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Form(
          key: cubit.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: RoleContextChip(role: UserRole.faculty)),
              const SizedBox(height: AppTheme.spaceLg),
              BlocBuilder<TeacherRegisterCubit, TeacherRegisterState>(
                builder: (context, state) {
                  return FormSectionCard(
                    icon: Icons.person_outline,
                    title: 'register.personalInfo'.tr(),
                    description: 'register.personalInfoDesc'.tr(),
                    children: [
                      AppImagePickerField(
                        label: 'common.profilePhoto'.tr(),
                        imageBytes: state.photoBytes,
                        onChanged: cubit.photoChanged,
                        onRemove: cubit.removePhoto,
                      ),
                      AppTextField(
                        label: 'common.name'.tr(),
                        icon: Icons.person_outline,
                        hint: 'common.fullNameHint'.tr(),
                        initialValue: state.fullName,
                        onChanged: cubit.fullNameChanged,
                        validator: Validators.required,
                      ),
                      AppTextField(
                        label: 'common.email'.tr(),
                        icon: Icons.mail_outline,
                        hint: 'common.emailHint'.tr(),
                        initialValue: state.email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: cubit.emailChanged,
                        validator: Validators.email,
                      ),
                      AppTextField(
                        label: 'common.phone'.tr(),
                        icon: Icons.phone_outlined,
                        hint: 'common.phoneHint'.tr(),
                        initialValue: state.phone,
                        keyboardType: TextInputType.phone,
                        onChanged: cubit.phoneChanged,
                        validator: Validators.phone,
                      ),
                      AppPasswordField(
                        label: 'common.password'.tr(),
                        hint: 'register.newPasswordHint'.tr(),
                        initialValue: state.password,
                        onChanged: cubit.passwordChanged,
                        obscureText: state.obscurePassword,
                        onToggleObscure: cubit.toggleObscurePassword,
                        validator: Validators.password,
                      ),
                      AppPasswordField(
                        label: 'common.confirmPassword'.tr(),
                        hint: 'register.confirmPasswordHint'.tr(),
                        initialValue: state.confirmPassword,
                        onChanged: cubit.confirmPasswordChanged,
                        obscureText: state.obscureConfirmPassword,
                        onToggleObscure: cubit.toggleObscureConfirmPassword,
                        validator: Validators.confirmPassword(
                          () => cubit.state.password,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceMd),
              BlocBuilder<TeacherRegisterCubit, TeacherRegisterState>(
                builder: (context, state) {
                  return FormSectionCard(
                    icon: Icons.co_present_outlined,
                    title: 'teacher.professionalInfo'.tr(),
                    description: 'teacher.professionalInfoDesc'.tr(),
                    children: [
                      AppTextField(
                        label: 'teacher.teacherId'.tr(),
                        icon: Icons.badge_outlined,
                        hint: 'teacher.teacherIdHint'.tr(),
                        initialValue: state.teacherId,
                        onChanged: cubit.teacherIdChanged,
                        validator: Validators.required,
                      ),
                      AppDropdownField<String>(
                        label: 'common.department'.tr(),
                        icon: Icons.apartment_outlined,
                        hint: 'common.selectOption'.tr(),
                        value: state.department,
                        items: kDepartmentOptions,
                        itemLabel: (department) => department,
                        onChanged: cubit.departmentChanged,
                      ),
                      AppDropdownField<TeacherDesignation>(
                        label: 'teacher.designation'.tr(),
                        icon: Icons.workspace_premium_outlined,
                        hint: 'common.selectOption'.tr(),
                        value: state.designation,
                        items: TeacherDesignation.values,
                        itemLabel: (designation) => designation.labelKey.tr(),
                        onChanged: cubit.designationChanged,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              BlocBuilder<TeacherRegisterCubit, TeacherRegisterState>(
                builder: (context, state) {
                  return PrimaryActionButton(
                    label: 'common.register'.tr(),
                    isLoading: state.status == SubmissionStatus.submitting,
                    onPressed: cubit.submit,
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              AuthFooterLink(
                promptKey: 'register.hasAccount',
                actionKey: 'common.login',
                onTap: () => context.pushReplacement(
                  AppRoute.loginPathFor(UserRole.faculty),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
