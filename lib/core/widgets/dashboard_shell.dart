import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/widgets/dashboard_shell_cubit.dart';

/// One tab in the dashboard bottom-nav shell — an icon plus a label that
/// will be run through `easy_localization` at build time.
class DashboardNavItem {
  const DashboardNavItem({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;
}

/// Bottom navigation shell shared by the student and teacher dashboards.
/// Each tab maps to a top-level destination in the redesigned home
/// experience (Home, Routine, Notices, Profile). Only the [Home] tab is
/// wired today — the others render a placeholder showing they're part
/// of the same nav shell, ready to be filled in by upcoming feature
/// work.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.tabs,
    required this.initialIndex,
    required this.navItems,
    super.key,
  });

  /// One widget per nav destination, indexed by the matching entry in
  /// [navItems]. Order must match.
  final List<Widget> tabs;

  final int initialIndex;
  final List<DashboardNavItem> navItems;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardShellCubit(
        initialIndex: initialIndex,
        tabCount: tabs.length,
      ),
      child: _ShellView(tabs: tabs, navItems: navItems),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView({required this.tabs, required this.navItems});

  final List<Widget> tabs;
  final List<DashboardNavItem> navItems;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardShellCubit, int>(
      builder: (context, index) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(index: index, children: tabs),
          ),
          bottomNavigationBar: _DashboardBottomNav(
            items: navItems,
            currentIndex: index,
            onTap: (i) => context.read<DashboardShellCubit>().selectTab(i),
          ),
        );
      },
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<DashboardNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    isActive: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final DashboardNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryFixed
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 20, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              item.labelKey.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}