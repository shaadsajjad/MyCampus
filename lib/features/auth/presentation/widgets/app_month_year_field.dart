import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/month_year_picker.dart';
import 'package:mycampus/features/auth/presentation/widgets/field_label.dart';

/// A labeled, tap-to-open month + year picker field bound to a Cubit's
/// state — mirrors `AppTextField` but for a `DateTime?` (day is ignored).
class AppMonthYearField extends StatelessWidget {
  const AppMonthYearField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.isRequired = true,
    this.hint,
    this.firstYear,
    this.lastYear,
    super.key,
  });

  final String label;
  final IconData icon;
  final DateTime? value;

  /// Only ever invoked with a real value — nothing calls this with `null`.
  final ValueChanged<DateTime> onChanged;
  final bool isRequired;
  final String? hint;
  final int? firstYear;
  final int? lastYear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppTheme.spaceXs),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () async {
            final picked = await showMonthYearPicker(
              context,
              initialDate: value,
              firstYear: firstYear,
              lastYear: lastYear,
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
              ),
            ),
            isEmpty: value == null,
            child: value != null
                ? Text(
                    DateFormat.yMMMM().format(value!),
                    style: textTheme.bodyLarge,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
