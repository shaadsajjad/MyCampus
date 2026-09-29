import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/utils/validators.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/auth/presentation/cubit/login_cubit.dart';
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
      child: Form(
        key: cubit.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: RoleContextChip(role: role)),
            const SizedBox(height: AppTheme.spaceLg),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
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
            PrimaryActionButton(
              label: 'common.login'.tr(),
              onPressed: cubit.submit,
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
    );
  }
}
