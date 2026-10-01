import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/domain/entities/day_of_week.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';
import 'package:mycampus/features/routine/presentation/cubit/routine_cubit.dart';
import 'package:mycampus/features/routine/presentation/widgets/compose_routine_slot_sheet.dart';
import 'package:mycampus/features/routine/presentation/widgets/routine_slot_card.dart';

/// The super admin's weekly-timetable builder, reached by **pushing**
/// `AppRoute.routine` from the Home tab's "Academic Registry" card (see
/// `AcademicRegistryCard`) — like `CoursesPage`, a standalone route rather
/// than a tab body (the bottom nav is already full), so it owns its own
/// [AppBar] from the start.
class RoutinePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutineCubit(),
      child: const _RoutineView(),
    );
  }
}

class _RoutineView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoutineCubit>();

    return BlocConsumer<RoutineCubit, RoutineState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(title: Text('routine.title'.tr())),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await ComposeRoutineSlotSheet.show(context);
              if (created == true) await cubit.load();
            },
            icon: const Icon(Icons.add),
            label: Text('routine.addSlot'.tr()),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                80,
              ),
              children: [
                Text(
                  'routine.desc'.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                if (state.status == RoutineStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == RoutineStatus.error)
                  _ErrorState(message: state.errorMessage ?? '')
                else if (state.slots.isEmpty)
                  const _EmptyState()
                else
                  for (final day in DayOfWeek.values)
                    if ((state.slotsByDay[day] ?? const []).isNotEmpty)
                      _DaySection(
                        day: day,
                        slots: state.slotsByDay[day]!,
                        pendingDeleteIds: state.pendingDeleteIds,
                        onDelete: (slot) => _confirmDelete(context, slot),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Deleting a slot is destructive, so it goes through a confirmation
  /// rather than firing on the first tap — same pattern as `CoursesPage`.
  Future<void> _confirmDelete(BuildContext context, RoutineSlot slot) async {
    final cubit = context.read<RoutineCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('routine.deleteTitle'.tr()),
        content: Text(
          'routine.deleteBody'.tr(
            namedArgs: {'code': slot.courseCode, 'title': slot.courseTitle},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete(slot.id);
  }
}

class _DaySection extends StatelessWidget {
  const new({
    required this.day,
    required this.slots,
    required this.pendingDeleteIds,
    required this.onDelete,
  });

  final DayOfWeek day;
  final List<RoutineSlot> slots;
  final Set<String> pendingDeleteIds;
  final ValueChanged<RoutineSlot> onDelete;

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
            RoutineSlotCard(
              slot: slot,
              isBusy: pendingDeleteIds.contains(slot.id),
              onDelete: () => onDelete(slot),
            ),
            const SizedBox(height: AppTheme.spaceSm),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const new({required this.message});

  final String message;

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
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'routine.noSlots'.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
