import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/presentation/cubit/my_routine_cubit.dart';
import 'package:mycampus/features/routine/presentation/widgets/routine_slot_card.dart';

/// The Routine tab inside the student and teacher dashboards — the
/// read-only weekly timetable a super admin builds; identical for every
/// member of the university (no department/section filtering yet).
///
/// Embedded as a tab body via `DashboardShell`, so it provides its own
/// [MyRoutineCubit] the way a page normally would but has no `Scaffold` or
/// bottom nav of its own — those come from the shell. Mirrors
/// `MemberNoticesPage`'s shape.
class MyRoutinePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyRoutineCubit(),
      child: const _MyRoutineView(),
    );
  }
}

class _MyRoutineView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyRoutineCubit>();

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: BlocBuilder<MyRoutineCubit, MyRoutineState>(
        builder: (context, state) {
          if (state.status == MyRoutineStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MyRoutineStatus.error) {
            return _ScrollableMessage(
              icon: Icons.cloud_off,
              title: 'routine.loadFailed'.tr(),
              message: state.errorMessage,
              actionLabel: 'profile.retry'.tr(),
              onAction: cubit.load,
            );
          }
          if (state.slots.isEmpty) {
            return const _ScrollableMessage(
              icon: Icons.calendar_month_outlined,
              titleKey: 'routine.myRoutineEmpty',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceXl,
            ),
            children: [
              for (final day in DayOfWeek.values)
                if ((state.slotsByDay[day] ?? const []).isNotEmpty)
                  _DaySection(day: day, slots: state.slotsByDay[day]!),
            ],
          );
        },
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const new({required this.day, required this.slots});

  final DayOfWeek day;
  final List<RoutineSlot> slots;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.labelKey.tr(),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          for (final slot in slots) ...[
            RoutineSlotCard(slot: slot),
            const SizedBox(height: AppTheme.spaceSm),
          ],
        ],
      ),
    );
  }
}

/// Shared empty/error layout: stays scrollable so pull-to-refresh keeps
/// working even when there is nothing to show. Copied from
/// `MemberNoticesPage`'s private `_ScrollableMessage` — feature-local
/// duplication, same as every other per-feature `_guard`/DTO copy.
class _ScrollableMessage extends StatelessWidget {
  const new({
    required this.icon,
    this.title,
    this.titleKey,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String? title;
  final String? titleKey;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = title ?? titleKey?.tr() ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 48, color: textTheme.bodySmall?.color),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      heading,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        message!,
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppTheme.spaceMd),
                      OutlinedButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.refresh),
                        label: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
