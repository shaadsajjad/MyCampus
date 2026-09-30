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
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/auth/domain/entities/university_type.dart';
import 'package:mycampus/features/auth/presentation/cubit/submission_status.dart';
import 'package:mycampus/features/auth/presentation/cubit/super_admin_register_cubit.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_dropdown_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_month_year_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_password_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mycampus/features/auth/presentation/widgets/form_section_card.dart';
import 'package:mycampus/features/auth/presentation/widgets/role_context_chip.dart';

class SuperAdminRegisterPage extends StatelessWidget {
  const SuperAdminRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuperAdminRegisterCubit(),
      child: const SuperAdminRegisterView(),
    );
  }
}

class SuperAdminRegisterView extends StatelessWidget {
  const SuperAdminRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperAdminRegisterCubit>();

    return AuthScaffold(
      title: 'university.createTitle'.tr(),
      subtitle: 'university.createSubtitle'.tr(),
      child: BlocListener<SuperAdminRegisterCubit, SuperAdminRegisterState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == SubmissionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('university.createdSuccess'.tr())),
            );
            context.go(AppRoute.dashboard);
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
              const Center(child: RoleContextChip(role: UserRole.superAdmin)),
              const SizedBox(height: AppTheme.spaceLg),
              BlocBuilder<SuperAdminRegisterCubit, SuperAdminRegisterState>(
                builder: (context, state) {
                  return FormSectionCard(
                    icon: Icons.account_balance,
                    title: 'admin.universityInfo'.tr(),
                    description: 'admin.universityInfoDesc'.tr(),
                    children: [
                      AppImagePickerField(
                        label: 'admin.universityLogo'.tr(),
                        shape: ImagePickerShape.roundedSquare,
                        imageBytes: state.logoBytes,
                        onChanged: cubit.logoChanged,
                        onRemove: cubit.removeLogo,
                      ),
                      AppTextField(
                        label: 'admin.universityName'.tr(),
                        icon: Icons.school_outlined,
                        hint: 'admin.universityNameHint'.tr(),
                        initialValue: state.universityName,
                        onChanged: cubit.universityNameChanged,
                        validator: Validators.required,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'admin.universityShort'.tr(),
                              icon: Icons.badge_outlined,
                              hint: 'admin.universityShortHint'.tr(),
                              initialValue: state.shortName,
                              onChanged: cubit.shortNameChanged,
                              validator: Validators.required,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: AppDropdownField<UniversityType>(
                              label: 'admin.universityType'.tr(),
                              icon: Icons.category_outlined,
                              hint: 'common.selectOption'.tr(),
                              value: state.universityType,
                              items: UniversityType.values,
                              itemLabel: (type) => type.labelKey.tr(),
                              onChanged: cubit.universityTypeChanged,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'admin.universityCity'.tr(),
                              icon: Icons.location_city_outlined,
                              hint: 'admin.universityCityHint'.tr(),
                              initialValue: state.city,
                              onChanged: cubit.cityChanged,
                              validator: Validators.required,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: AppTextField(
                              label: 'admin.universityCountry'.tr(),
                              icon: Icons.public,
                              hint: 'admin.universityCountryHint'.tr(),
                              initialValue: state.country,
                              onChanged: cubit.countryChanged,
                              validator: Validators.required,
                            ),
                          ),
                        ],
                      ),
                      AppMonthYearField(
                        label: 'admin.establishedYear'.tr(),
                        icon: Icons.calendar_today_outlined,
                        hint: 'admin.establishedYearHint'.tr(),
                        value: state.establishedAt,
                        isRequired: false,
                        lastYear: DateTime.now().year,
                        onChanged: cubit.establishedAtChanged,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceMd),
              BlocBuilder<SuperAdminRegisterCubit, SuperAdminRegisterState>(
                builder: (context, state) {
                  return FormSectionCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'admin.adminInfo'.tr(),
                    description: 'admin.adminInfoDesc'.tr(),
                    children: [
                      AppTextField(
                        label: 'common.name'.tr(),
                        icon: Icons.person_outline,
                        hint: 'common.fullNameHint'.tr(),
                        initialValue: state.adminName,
                        onChanged: cubit.adminNameChanged,
                        validator: Validators.required,
                      ),
                      AppTextField(
                        label: 'common.email'.tr(),
                        icon: Icons.mail_outline,
                        hint: 'common.emailHint'.tr(),
                        initialValue: state.adminEmail,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: cubit.adminEmailChanged,
                        validator: Validators.email,
                      ),
                      AppPasswordField(
                        label: 'common.password'.tr(),
                        hint: 'auth.newPasswordHint'.tr(),
                        initialValue: state.adminPassword,
                        onChanged: cubit.adminPasswordChanged,
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
                          () => cubit.state.adminPassword,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              BlocBuilder<SuperAdminRegisterCubit, SuperAdminRegisterState>(
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
                promptKey: 'auth.hasAccount',
                actionKey: 'common.login',
                onTap: () => context.pushReplacement(
                  AppRoute.loginPathFor(UserRole.superAdmin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
