import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/auth/presentation/login/login_cubit.dart';
import 'package:mycampus/features/auth/presentation/submission_status.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_password_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/app_text_field.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:mycampus/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mycampus/features/auth/presentation/widgets/role_context_chip.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: LoginView(role: role),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return AuthScaffold(
      title: 'auth.loginTitle'.tr(),
      subtitle: 'auth.loginSubtitle'.tr(),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            previous.status != current.status || previous.result != current.result,
        listener: (context, state) {
          if (state.status == SubmissionStatus.success &&
              state.result == LoginResult.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('auth.loginSuccess'.tr())));
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
              Center(child: RoleContextChip(role: role)),
              const SizedBox(height: AppTheme.spaceLg),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  // Show email not verified UI
                  if (state.result == LoginResult.emailNotVerified) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spaceMd),
                          decoration: BoxDecoration(
                            color: AppColors.brandTint,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.mark_email_unread_outlined,
                                color: AppColors.brandAccentText,
                                size: 32,
                              ),
                              const SizedBox(height: AppTheme.spaceSm),
                              Text(
                                'login.emailNotVerifiedTitle'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          AppColors.brandAccentText,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spaceXs),
                              Text(
                                'login.emailNotVerifiedDesc'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          AppColors.brandAccentText,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon:
                                          const Icon(Icons.email_outlined),
                                      label: Text(
                                        'login.resendVerification'.tr(),
                                      ),
                                      onPressed: state.status ==
                                              SubmissionStatus.submitting
                                          ? null
                                          : cubit.resendVerificationEmail,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSm),
                                  Expanded(
                                    child: PrimaryActionButton(
                                      label: 'login.goToVerification'.tr(),
                                      onPressed: () => context.go(
                                        AppRoute.verificationPath(
                                          state.email,
                                        ),
                                        extra: state.password,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'common.email'.tr(),
                        icon: Icons.mail_outline,
                        hint: 'common.emailHint'.tr(),
                        initialValue: state.email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: cubit.emailChanged,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      AppPasswordField(
                        label: 'common.password'.tr(),
                        hint: 'auth.loginPasswordHint'.tr(),
                        initialValue: state.password,
                        onChanged: cubit.passwordChanged,
                        obscureText: state.obscurePassword,
                        onToggleObscure: cubit.toggleObscurePassword,
                        validator: Validators.required,
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  // TODO(pocketbase): wire up the forgot-password flow.
                  onPressed: () {},
                  child: Text('auth.forgotPassword'.tr()),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return PrimaryActionButton(
                    label: 'common.login'.tr(),
                    isLoading: state.status == SubmissionStatus.submitting,
                    onPressed: cubit.submit,
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              AuthFooterLink(
                promptKey: 'auth.noAccount',
                actionKey: 'common.register',
                onTap: () =>
                    context.pushReplacement(AppRoute.registerPathFor(role)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
