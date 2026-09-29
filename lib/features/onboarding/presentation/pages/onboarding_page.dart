import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/onboarding/domain/entities/auth_mode.dart';
import 'package:mycampus/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mycampus/features/onboarding/presentation/models/role_option.dart';
import 'package:mycampus/features/onboarding/presentation/widgets/auth_toggle.dart';
import 'package:mycampus/features/onboarding/presentation/widgets/brand_header.dart';
import 'package:mycampus/features/onboarding/presentation/widgets/role_card.dart';
import 'package:mycampus/features/onboarding/presentation/widgets/security_footer.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildRoleSection(context),
              const SizedBox(height: AppTheme.spaceLg),
              _buildContinueButton(context),
              const SizedBox(height: AppTheme.spaceMd),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return AuthToggle(
                    currentMode: state.authMode,
                    onToggle: (mode) =>
                        context.read<OnboardingCubit>().toggleAuthMode(mode),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              const SecurityFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('roles.selectRole'.tr(), style: textTheme.headlineSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm,
                vertical: AppTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'splash.stepOf'.tr(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.brandAccentText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text('splash.chooseAccess'.tr(), style: textTheme.bodySmall),
        const SizedBox(height: AppTheme.spaceMd),
        BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Column(
              children: [
                for (final option in kRoleOptions) ...[
                  RoleCard(
                    option: option,
                    isSelected: state.selectedRole == option.role,
                    onTap: () =>
                        context.read<OnboardingCubit>().selectRole(
                          option.role,
                        ),
                  ),
                  if (option != kRoleOptions.last)
                    const SizedBox(height: AppTheme.spaceMd),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final roleName = state.selectedRole.labelKey.tr();
        final action = state.authMode == AuthMode.login
            ? 'common.continue'.tr()
            : 'common.register'.tr();
        return PrimaryActionButton(
          label: '$action $roleName',
          onPressed: () => state.authMode == AuthMode.login
              ? context.push(AppRoute.loginPathFor(state.selectedRole))
              : context.push(AppRoute.registerPathFor(state.selectedRole)),
        );
      },
    );
  }
}
