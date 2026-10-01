import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mycampus/features/student_dashboard/presentation/pages/student_dashboard_page.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/pages/super_admin_dashboard_page.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/pages/teacher_dashboard_page.dart';

/// Landing page shown right after a successful login or registration —
/// routes to the role-specific dashboard. [DashboardView] below is only a
/// fallback for the (normally unreachable) case where [role] is still
/// `null` — e.g. no signed-in user.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: BlocSelector<DashboardCubit, DashboardState, UserRole?>(
        selector: (state) => state.role,
        builder: (context, role) => switch (role) {
          UserRole.superAdmin => const SuperAdminDashboardPage(),
          UserRole.student => const StudentDashboardPage(),
          UserRole.faculty => const TeacherDashboardPage(),
          null => const DashboardView(),
        },
      ),
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
        return Scaffold(
          appBar: AppBar(
            title: Text('common.dashboard'.tr()),
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
                    state.name ?? state.email ?? '',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(state.email ?? '', style: textTheme.bodyMedium),
                  if (state.isPending) ...[
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
}
