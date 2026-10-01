import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/section_header.dart';
import 'package:mycampus/features/member_directory/presentation/cubit/member_directory_cubit.dart';
import 'package:mycampus/features/member_directory/presentation/widgets/directory_member_card.dart';

/// The super admin's "Directory" tab — every approved student and faculty
/// member of their university, searchable and filterable by role. Embedded as
/// a tab body (via `SuperAdminDashboardPage`'s bottom nav), not a standalone
/// route, so it provides its own [MemberDirectoryCubit] the same way a page
/// normally would.
///
/// Deliberately separate from the join-requests tab: that one is a work
/// queue (pending only, with approve/reject actions), this one is a
/// reference list of everyone already on campus.
class MemberDirectoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemberDirectoryCubit(),
      child: const _MemberDirectoryView(),
    );
  }
}

class _MemberDirectoryView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemberDirectoryCubit>();

    return BlocBuilder<MemberDirectoryCubit, MemberDirectoryState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              SectionHeader(
                icon: Icons.groups,
                title: 'directory.title'.tr(),
                description: 'directory.desc'.tr(),
                // Courses live one level down rather than as a 6th
                // bottom-nav tab (Material's own guidance stops at 5, and
                // the bar was already full) — both screens are the same
                // "campus registry" concern, so a link between them reads
                // naturally.
                trailing: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoute.courses),
                  icon: const Icon(Icons.school, size: 18),
                  label: Text('directory.manageCourses'.tr()),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              _SearchField(onChanged: cubit.search),
              const SizedBox(height: AppTheme.spaceSm),
              _FilterPills(state: state, onSelect: cubit.setFilter),
              const SizedBox(height: AppTheme.spaceMd),
              if (state.status == MemberDirectoryStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == MemberDirectoryStatus.error)
                _ErrorState(
                  message: state.errorMessage ?? '',
                  onRetry: cubit.load,
                )
              else if (state.visibleMembers.isEmpty)
                _EmptyState(query: state.query)
              else
                Column(
                  children: [
                    for (final member in state.visibleMembers) ...[
                      DirectoryMemberCard(member: member),
                      const SizedBox(height: AppTheme.spaceSm),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const new({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'directory.search'.tr(),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  const new({required this.state, required this.onSelect});

  final MemberDirectoryState state;
  final ValueChanged<MemberDirectoryFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Pill(
            label: 'directory.filterAll'.tr(),
            count: state.members.length,
            isActive: state.filter == MemberDirectoryFilter.all,
            onTap: () => onSelect(MemberDirectoryFilter.all),
          ),
          _Pill(
            label: 'roles.student'.tr(),
            count: state.studentCount,
            isActive: state.filter == MemberDirectoryFilter.students,
            onTap: () => onSelect(MemberDirectoryFilter.students),
          ),
          _Pill(
            label: 'roles.faculty'.tr(),
            count: state.facultyCount,
            isActive: state.filter == MemberDirectoryFilter.faculty,
            onTap: () => onSelect(MemberDirectoryFilter.faculty),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const new({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background = isActive
        ? AppColors.primary
        : colorScheme.surfaceContainerHigh;
    final foreground = isActive
        ? AppColors.onPrimary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spaceSm),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(color: foreground),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.2)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '$count',
                    style: textTheme.labelSmall?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const new({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            message,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const new({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasQuery = query.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.group_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            hasQuery ? 'directory.noResults'.tr() : 'directory.noMembers'.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
