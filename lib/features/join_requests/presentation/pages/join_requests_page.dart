import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/join_requests/domain/entities/member_request.dart';
import 'package:mycampus/features/join_requests/presentation/cubit/join_requests_cubit.dart';
import 'package:mycampus/features/join_requests/presentation/widgets/member_card.dart';

/// The super admin's "Requests" tab — reviewing and approving/rejecting
/// pending student/faculty accounts for their university, plus an archive
/// of already-decided ones. Embedded as a tab body (via
/// `SuperAdminDashboardPage`'s bottom nav), not a standalone route, so it
/// provides its own [JoinRequestsCubit] the same way a page normally would.
class JoinRequestsPage extends StatelessWidget {
  const JoinRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinRequestsCubit(),
      child: const _JoinRequestsView(),
    );
  }
}

class _JoinRequestsView extends StatelessWidget {
  const _JoinRequestsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JoinRequestsCubit>();

    return BlocBuilder<JoinRequestsCubit, JoinRequestsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              _Header(pendingCount: state.pendingCount),
              const SizedBox(height: AppTheme.spaceMd),
              _SearchField(onChanged: cubit.search),
              const SizedBox(height: AppTheme.spaceSm),
              _FilterPills(state: state, onSelect: cubit.setFilter),
              const SizedBox(height: AppTheme.spaceSm),
              if (state.filter != JoinRequestsFilter.archived)
                _BatchActionBar(state: state, cubit: cubit),
              const SizedBox(height: AppTheme.spaceMd),
              if (state.status == JoinRequestsStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.visibleMembers.isEmpty)
                _EmptyState(filter: state.filter)
              else
                Column(
                  children: [
                    for (final member in state.visibleMembers) ...[
                      MemberCard(
                        member: member,
                        isSelected: state.selectedIds.contains(member.id),
                        isBusy: state.pendingActionIds.contains(member.id),
                        onToggleSelected: () => cubit.toggleSelected(member.id),
                        onApprove: () => cubit.approve(member.id),
                        onReject: () => cubit.reject(member.id),
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'admin.joinRequests'.tr(),
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: AppTheme.spaceXs),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              Text('admin.joinRequestsDesc'.tr(), style: textTheme.bodySmall),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'admin.searchApplicants'.tr(),
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
  const _FilterPills({required this.state, required this.onSelect});

  final JoinRequestsState state;
  final ValueChanged<JoinRequestsFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Pill(
            label: 'admin.filterAllPending'.tr(),
            count: state.pendingCount,
            isActive: state.filter == JoinRequestsFilter.allPending,
            onTap: () => onSelect(JoinRequestsFilter.allPending),
          ),
          _Pill(
            label: 'roles.student'.tr(),
            count: state.studentCount,
            isActive: state.filter == JoinRequestsFilter.students,
            onTap: () => onSelect(JoinRequestsFilter.students),
          ),
          _Pill(
            label: 'roles.faculty'.tr(),
            count: state.facultyCount,
            isActive: state.filter == JoinRequestsFilter.faculty,
            onTap: () => onSelect(JoinRequestsFilter.faculty),
          ),
          _Pill(
            label: 'admin.filterArchived'.tr(),
            count: state.archivedCount,
            isActive: state.filter == JoinRequestsFilter.archived,
            onTap: () => onSelect(JoinRequestsFilter.archived),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({required this.state, required this.cubit});

  final JoinRequestsState state;
  final JoinRequestsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final pendingVisible = state.visibleMembers
        .where((m) => m.status == MemberStatus.pending)
        .length;
    final allSelected =
        pendingVisible > 0 && state.selectedIds.length == pendingVisible;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: allSelected,
                onChanged: pendingVisible == 0
                    ? null
                    : (value) => cubit.selectAllVisible(select: value ?? false),
              ),
              Text(
                'admin.selectAll'.tr(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: state.selectedIds.isEmpty ? null : cubit.batchApprove,
            icon: const Icon(Icons.verified, size: 18),
            label: Text(
              'admin.batchApprove'.tr(
                namedArgs: {'count': '${state.selectedIds.length}'},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final JoinRequestsFilter filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            filter == JoinRequestsFilter.archived
                ? Icons.inbox
                : Icons.task_alt,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            filter == JoinRequestsFilter.archived
                ? 'admin.noArchivedRequests'.tr()
                : 'admin.noPendingRequests'.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
