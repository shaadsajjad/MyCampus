import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/widgets/empty_state_prompt.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/student_dashboard/presentation/cubit/student_dashboard_cubit.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/student_home_view.dart';

/// The student's landing page after login/registration. Shows a join
/// prompt (none/rejected), a pending-approval message, or the redesigned
/// home screen — all three states driven by [StudentDashboardCubit.load].
/// Also subscribes to realtime updates on the student's own `users`
/// record so the page transitions automatically from "waiting for
/// approval" to the home dashboard the moment a super admin approves or
/// rejects the request.
class StudentDashboardPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentDashboardCubit(),
      child: const _StudentDashboardView(),
    );
  }
}

class _StudentDashboardView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudentDashboardCubit>();

    return BlocConsumer<StudentDashboardCubit, StudentDashboardState>(
      listenWhen: (previous, current) =>
          previous.membership != current.membership ||
          previous.justApproved != current.justApproved,
      listener: (context, state) {
        if (state.justApproved && state.membership == MembershipStatus.approved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('student.welcomeApproved'.tr()),
                backgroundColor: AppColors.secondary,
              ),
            );
          cubit.clearJustApproved();
        } else if (state.membership == MembershipStatus.rejected) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('student.welcomeRejected'.tr()),
                backgroundColor: AppColors.error,
              ),
            );
        }
      },
      builder: (context, state) {
        return switch (state.membership) {
          MembershipStatus.none ||
          MembershipStatus.rejected => Scaffold(
              appBar: AppBar(
                title: Text('student.dashboard'.tr()),
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
              body: EmptyStatePrompt(
                icon: Icons.qr_code_scanner,
                title: 'student.joinTitle'.tr(),
                description: 'student.joinDesc'.tr(),
                bannerText: state.membership == MembershipStatus.rejected
                    ? 'student.rejectedNotice'.tr()
                    : null,
                bannerColor: AppColors.error,
                actionLabel: 'common.scan'.tr(),
                onAction: () => _openScanner(context),
              ),
            ),
          MembershipStatus.pending => Scaffold(
              appBar: AppBar(
                title: Text('student.dashboard'.tr()),
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
              body: EmptyStatePrompt(
                icon: Icons.hourglass_top_outlined,
                title: state.university?.name ?? 'student.joinTitle'.tr(),
                description: 'status.waitingApproval'.tr(),
                bannerText: 'status.pending'.tr(),
              ),
            ),
          MembershipStatus.approved => StudentHomeView(
              name: state.name,
              email: state.email,
              university: state.university,
              avatarUrl: state.avatarUrl,
              studentId: state.profile?.studentId ?? '',
              program: state.profile == null
                  ? ''
                  : '${state.profile!.department} • Sem ${state.profile!.batch}',
            ),
        };
      },
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final cubit = context.read<StudentDashboardCubit>();
    final joined = await context.push<bool>(AppRoute.joinUniversity);
    if (joined ?? false) {
      await cubit.load();
    }
  }
}