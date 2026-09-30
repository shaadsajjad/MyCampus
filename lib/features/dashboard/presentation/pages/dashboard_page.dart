import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/auth/domain/entities/account_status.dart';
import 'package:mycampus/features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// Placeholder landing page shown right after a successful login or
/// registration. Confirms the PocketBase round-trip worked; the real
/// role-specific dashboards (attendance, notices, approvals, ...) are a
/// separate, later feature.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<DashboardCubit>();

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(_titleFor(user?.role)),
            actions: [
              IconButton(
                tooltip: 'common.logout'.tr(),
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await cubit.logout();
                  if (context.mounted) context.go(AppRoute.onboarding);
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    user?.name ?? user?.email ?? '',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(user?.email ?? '', style: textTheme.bodyMedium),
                  if (user?.status == AccountStatus.pending) ...[
                    const SizedBox(height: AppTheme.spaceLg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        'status.waitingApproval'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.brandAccentText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _titleFor(UserRole? role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'admin.dashboard'.tr();
      case UserRole.faculty:
        return 'teacher.dashboard'.tr();
      case UserRole.student:
        return 'student.dashboard'.tr();
      case null:
        return 'common.dashboard'.tr();
    }
  }
}
