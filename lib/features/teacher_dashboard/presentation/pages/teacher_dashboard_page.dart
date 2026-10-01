import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/widgets/empty_state_prompt.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/membership_status.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/cubit/teacher_dashboard_cubit.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/teacher_home_view.dart';

/// The teacher's landing page after login/registration. Shows a join
/// prompt (none/rejected), a pending-approval message, or the redesigned
/// home screen — all three states driven by
/// [TeacherDashboardCubit.load]. Also subscribes to realtime updates on
/// the teacher's own `users` record so the page transitions
/// automatically from "waiting for approval" to the home dashboard the
/// moment a super admin approves or rejects the request.
class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherDashboardCubit(),
      child: const _TeacherDashboardView(),
    );
  }
}

class _TeacherDashboardView extends StatelessWidget {
  const _TeacherDashboardView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TeacherDashboardCubit>();

    return BlocConsumer<TeacherDashboardCubit, TeacherDashboardState>(
      listenWhen: (previous, current) =>
          previous.membership != current.membership ||
          previous.justApproved != current.justApproved,
      listener: (context, state) {
        if (state.justApproved && state.membership == MembershipStatus.approved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('teacher.welcomeApproved'.tr()),
                backgroundColor: AppColors.secondary,
              ),
            );
          cubit.clearJustApproved();
        } else if (state.membership == MembershipStatus.rejected) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('teacher.welcomeRejected'.tr()),
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
                title: Text('teacher.dashboard'.tr()),
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
                title: 'teacher.joinTitle'.tr(),
                description: 'teacher.joinDesc'.tr(),
                bannerText: state.membership == MembershipStatus.rejected
                    ? 'teacher.rejectedNotice'.tr()
                    : null,
                bannerColor: AppColors.error,
                actionLabel: 'common.scan'.tr(),
                onAction: () => _openScanner(context),
              ),
            ),
          MembershipStatus.pending => Scaffold(
              appBar: AppBar(
                title: Text('teacher.dashboard'.tr()),
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
                title: state.university?.name ?? 'teacher.joinTitle'.tr(),
                description: 'status.waitingApproval'.tr(),
                bannerText: 'status.pending'.tr(),
              ),
            ),
          MembershipStatus.approved => TeacherHomeView(
              name: state.name,
              email: state.email,
              university: state.university,
              avatarUrl: state.avatarUrl,
              teacherId: state.profile?.teacherId ?? '',
              department: state.profile?.department ?? '',
              designation: state.profile?.designation ?? 'Faculty',
            ),
        };
      },
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final cubit = context.read<TeacherDashboardCubit>();
    final joined = await context.push<bool>(AppRoute.joinUniversity);
    if (joined ?? false) {
      await cubit.load();
    }
  }
}