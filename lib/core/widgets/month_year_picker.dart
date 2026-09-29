import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Opens a custom month + year picker dialog (no day selection) and
/// resolves to the 1st of the chosen month, or `null` if dismissed.
Future<DateTime?> showMonthYearPicker(
  BuildContext context, {
  DateTime? initialDate,
  int? firstYear,
  int? lastYear,
}) {
  final now = DateTime.now();
  final initial = initialDate ?? now;
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _MonthYearPickerDialog(
      initialYear: initial.year,
      initialMonth: initial.month,
      firstYear: firstYear ?? now.year - 100,
      lastYear: lastYear ?? now.year,
    ),
  );
}

class _PickerState {
  const _PickerState({required this.year, required this.month});

  final int year;
  final int month;

  _PickerState copyWith({int? year, int? month}) {
    return _PickerState(year: year ?? this.year, month: month ?? this.month);
  }
}

class _PickerCubit extends Cubit<_PickerState> {
  _PickerCubit({required int year, required int month})
    : super(_PickerState(year: year, month: month));

  void previousYear() => emit(state.copyWith(year: state.year - 1));

  void nextYear() => emit(state.copyWith(year: state.year + 1));
}

class _MonthYearPickerDialog extends StatelessWidget {
  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.firstYear,
    required this.lastYear,
  });

  final int initialYear;
  final int initialMonth;
  final int firstYear;
  final int lastYear;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _PickerCubit(year: initialYear, month: initialMonth),
      child: _PickerView(firstYear: firstYear, lastYear: lastYear),
    );
  }
}

class _PickerView extends StatelessWidget {
  const _PickerView({required this.firstYear, required this.lastYear});

  final int firstYear;
  final int lastYear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<_PickerCubit>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: BlocBuilder<_PickerCubit, _PickerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'common.selectMonthYear'.tr(),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.year > firstYear
                          ? cubit.previousYear
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        '${state.year}',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: state.year < lastYear ? cubit.nextYear : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: AppTheme.spaceSm,
                  crossAxisSpacing: AppTheme.spaceSm,
                  childAspectRatio: 2.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var month = 1; month <= 12; month++)
                      _MonthTile(
                        month: month,
                        isSelected: month == state.month,
                        isEnabled: _isMonthEnabled(state.year, month),
                        onTap: () => Navigator.of(
                          context,
                        ).pop(DateTime(state.year, month)),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('common.cancel'.tr()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Blocks months after "now" when [lastYear] is the current year (the
  /// common "no future date" case) — years beyond that are already kept
  /// out of reach by the year-navigation chevrons.
  bool _isMonthEnabled(int year, int month) {
    final now = DateTime.now();
    if (lastYear == now.year && year == now.year && month > now.month) {
      return false;
    }
    return true;
  }
}

class _MonthTile extends StatelessWidget {
  const _MonthTile({
    required this.month,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final int month;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = DateFormat.MMM().format(DateTime(2024, month));

    return Material(
      color: isSelected ? AppColors.secondary : AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: isEnabled ? onTap : null,
        child: Center(
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: !isEnabled
                  ? AppColors.outline
                  : isSelected
                  ? AppColors.onSecondary
                  : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
