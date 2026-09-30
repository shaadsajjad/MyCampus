import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/constants/app_assets.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/join_requests/presentation/pages/join_requests_page.dart';
import 'package:mycampus/features/notices/presentation/pages/notices_page.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/cubit/campus_pass_cubit.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/cubit/super_admin_dashboard_cubit.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/widgets/access_metrics_row.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/widgets/campus_pass_card.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/widgets/join_requests_banner.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/widgets/security_policy_note.dart';
import 'package:mycampus/features/super_admin_dashboard/presentation/widgets/university_header_card.dart';
import 'package:mycampus/features/super_admin_profile/presentation/pages/super_admin_profile_page.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SuperAdminDashboardCubit()),
        BlocProvider(create: (_) => CampusPassCubit()),
      ],
      child: const _SuperAdminDashboardView(),
    );
  }
}

class _SuperAdminDashboardView extends StatelessWidget {
  const _SuperAdminDashboardView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperAdminDashboardCubit>();

    return BlocListener<CampusPassCubit, CampusPassState>(
      listenWhen: (previous, current) =>
          previous.outcome != current.outcome && current.outcome != null,
      listener: (context, passState) {
        final outcome = passState.outcome!;
        _showSnack(
          context,
          _messageFor(outcome),
          isError: outcome != CampusPassOutcome.saved,
        );
      },
      child: BlocBuilder<SuperAdminDashboardCubit, SuperAdminDashboardState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              centerTitle: false,
              titleSpacing: AppTheme.spaceMd,
              title: Row(
                children: [
                  Image.asset(AppAssets.logo, height: 32, fit: BoxFit.contain),
                  const SizedBox(width: AppTheme.spaceSm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'app.name'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _subtitleFor(state.tab),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'common.notifications'.tr(),
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showSnack(context, 'admin.comingSoon'.tr()),
                ),
                PopupMenuButton<_ProfileAction>(
                  icon: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  onSelected: (action) async {
                    switch (action) {
                      case _ProfileAction.profile:
                        cubit.selectTab(SuperAdminDashboardTab.profile);
                      case _ProfileAction.logout:
                        await cubit.logout();
                        if (context.mounted) context.go(AppRoute.onboarding);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ProfileAction.profile,
                      child: Text('admin.navProfile'.tr()),
                    ),
                    PopupMenuItem(
                      value: _ProfileAction.logout,
                      child: Text('common.logout'.tr()),
                    ),
                  ],
                ),
                const SizedBox(width: AppTheme.spaceXs),
              ],
            ),
            body: switch (state.tab) {
              SuperAdminDashboardTab.home => _HomeTab(state: state),
              SuperAdminDashboardTab.requests => const JoinRequestsPage(),
              SuperAdminDashboardTab.notices => const NoticesPage(),
              SuperAdminDashboardTab.profile => const SuperAdminProfilePage(),
            },
            bottomNavigationBar: _DashboardBottomNav(
              currentTab: state.tab,
              onSelect: cubit.selectTab,
              onUnavailableTap: () =>
                  _showSnack(context, 'admin.comingSoon'.tr()),
            ),
          );
        },
      ),
    );
  }

  String _subtitleFor(SuperAdminDashboardTab tab) => switch (tab) {
    SuperAdminDashboardTab.home => 'admin.dashboard'.tr(),
    SuperAdminDashboardTab.requests => 'admin.joinRequests'.tr(),
    SuperAdminDashboardTab.notices => 'admin.navNotices'.tr(),
    SuperAdminDashboardTab.profile => 'admin.navProfile'.tr(),
  };

  String _messageFor(CampusPassOutcome outcome) => switch (outcome) {
    CampusPassOutcome.saved => 'admin.qrSaved'.tr(),
    CampusPassOutcome.saveFailed => 'admin.qrSaveFailed'.tr(),
    CampusPassOutcome.shareFailed => 'admin.qrShareFailed'.tr(),
    CampusPassOutcome.permissionDenied => 'admin.photoPermissionDenied'.tr(),
    CampusPassOutcome.unsupported => 'admin.saveUnsupported'.tr(),
  };
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.state});

  final SuperAdminDashboardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperAdminDashboardCubit>();
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        children: [
          UniversityHeaderCard(
            university: state.university,
            fallbackName: state.adminName ?? state.adminEmail ?? '',
          ),
          const SizedBox(height: AppTheme.spaceLg),
          CampusPassCard(
            campusId: state.universityId,
            universityName: state.university?.name,
            onAction: (message) => _showSnack(context, message),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          AccessMetricsRow(stats: state.stats),
          if ((state.stats?.pendingRequests ?? 0) > 0) ...[
            const SizedBox(height: AppTheme.spaceLg),
            JoinRequestsBanner(
              pendingCount: state.stats!.pendingRequests,
              onReview: () => cubit.selectTab(SuperAdminDashboardTab.requests),
            ),
          ],
          const SizedBox(height: AppTheme.spaceLg),
          const SecurityPolicyNote(),
        ],
      ),
    );
  }
}

enum _ProfileAction { profile, logout }

/// Bottom-nav order: Home, Requests, Pass, Notices, Profile. Pass has no
/// screen yet, so it isn't a [SuperAdminDashboardTab].
class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.currentTab,
    required this.onSelect,
    required this.onUnavailableTap,
  });

  final SuperAdminDashboardTab currentTab;
  final ValueChanged<SuperAdminDashboardTab> onSelect;
  final VoidCallback onUnavailableTap;

  static const _noticesIndex = 3;
  static const _profileIndex = 4;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: switch (currentTab) {
        SuperAdminDashboardTab.home => 0,
        SuperAdminDashboardTab.requests => 1,
        SuperAdminDashboardTab.notices => _noticesIndex,
        SuperAdminDashboardTab.profile => _profileIndex,
      },
      type: BottomNavigationBarType.fixed,
      onTap: (index) => switch (index) {
        0 => onSelect(SuperAdminDashboardTab.home),
        1 => onSelect(SuperAdminDashboardTab.requests),
        _noticesIndex => onSelect(SuperAdminDashboardTab.notices),
        _profileIndex => onSelect(SuperAdminDashboardTab.profile),
        _ => onUnavailableTap(),
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view),
          label: 'admin.navHome'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.how_to_reg),
          label: 'admin.navRequests'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          label: 'admin.navPass'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.mark_email_unread_outlined),
          label: 'admin.navNotices'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle_outlined),
          activeIcon: const Icon(Icons.account_circle),
          label: 'admin.navProfile'.tr(),
        ),
      ],
    );
  }
}
