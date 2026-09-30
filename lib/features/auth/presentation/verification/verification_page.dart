import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/auth/presentation/verification/verification_cubit.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({required this.email, super.key, this.password});

  final String email;
  final String? password;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerificationCubit(email: email, password: password),
      child: VerificationView(email: email),
    );
  }
}

class VerificationView extends StatelessWidget {
  const VerificationView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerificationCubit, VerificationState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == VerificationStatus.verified) {
          context.go(state.sessionActive ? AppRoute.dashboard : AppRoute.login);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  'verification.checkYourEmail'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  'verification.weSentEmail'.tr(namedArgs: {'email': email}),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'verification.openEmailApp'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceXl),
                BlocBuilder<VerificationCubit, VerificationState>(
                  builder: (context, state) {
                    if (state.status == VerificationStatus.verifying) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (state.status == VerificationStatus.error) {
                      return Column(
                        children: [
                          Text(
                            state.errorMessage ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                PrimaryActionButton(
                  label: 'verification.resendEmail'.tr(),
                  onPressed: () =>
                      context.read<VerificationCubit>().resendEmail(),
                  isLoading: false,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TextButton(
                  onPressed: () => context.go(AppRoute.onboarding),
                  child: Text('verification.backToStart'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}