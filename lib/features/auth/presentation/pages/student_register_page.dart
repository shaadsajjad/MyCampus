import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/app_image_picker_field.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/auth/presentation/cubit/student_register_cubit.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_dropdown_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_password_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mycampus/features/auth/presentation/widgets/department_options.dart';
import 'package:mycampus/features/auth/presentation/widgets/form_section_card.dart';
import 'package:mycampus/features/auth/presentation/widgets/role_context_chip.dart';

class StudentRegisterPage extends StatelessWidget {
  const StudentRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentRegisterCubit(),
      child: const StudentRegisterView(),
    );
  }
}

class StudentRegisterView extends StatelessWidget {
  const StudentRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudentRegisterCubit>();

    return AuthScaffold(
      title: 'auth.registerTitle'.tr(),
      subtitle: 'auth.registerSubtitle'.tr(),
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: RoleContextChip(role: UserRole.student)),
            const SizedBox(height: AppTheme.spaceLg),
            BlocBuilder<StudentRegisterCubit, StudentRegisterState>(
              builder: (context, state) {
                return FormSectionCard(
                  icon: Icons.person_outline,
                  title: 'auth.personalInfo'.tr(),
                  description: 'auth.personalInfoDesc'.tr(),
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
                      hint: 'auth.newPasswordHint'.tr(),
                      initialValue: state.password,
                      onChanged: cubit.passwordChanged,
                      obscureText: state.obscurePassword,
                      onToggleObscure: cubit.toggleObscurePassword,
                      validator: Validators.password,
                    ),
                    AppPasswordField(
                      label: 'common.confirmPassword'.tr(),
                      hint: 'auth.confirmPasswordHint'.tr(),
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
            BlocBuilder<StudentRegisterCubit, StudentRegisterState>(
              builder: (context, state) {
                return FormSectionCard(
                  icon: Icons.school_outlined,
                  title: 'student.academicInfo'.tr(),
                  description: 'student.academicInfoDesc'.tr(),
                  children: [
                    AppTextField(
                      label: 'student.studentId'.tr(),
                      icon: Icons.badge_outlined,
                      hint: 'student.studentIdHint'.tr(),
                      initialValue: state.studentId,
                      onChanged: cubit.studentIdChanged,
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
                    AppTextField(
                      label: 'student.batch'.tr(),
                      icon: Icons.groups_outlined,
                      hint: 'student.batchHint'.tr(),
                      initialValue: state.batch,
                      onChanged: cubit.batchChanged,
                      validator: Validators.required,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            PrimaryActionButton(
              label: 'common.register'.tr(),
              onPressed: cubit.submit,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            AuthFooterLink(
              promptKey: 'auth.hasAccount',
              actionKey: 'common.login',
              onTap: () => context.pushReplacement(
                AppRoute.loginPathFor(UserRole.student),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
