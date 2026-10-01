import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/field_label.dart';

/// A labeled, tap-to-open time-of-day picker field bound to a Cubit's
/// state — mirrors `AppMonthYearField` (`register`'s date field) but for a
/// 24h `HH:mm` string. Feature-local for now since only `routine` has a
/// time-of-day field yet — see `clean_architecture.md`'s `core/` promotion
/// rule for when to move it.
class AppTimeField extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.isRequired = true,
    this.hint,
    super.key,
  });

  final String label;
  final IconData icon;

  /// 24h `HH:mm`, e.g. `09:30`.
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppTheme.spaceXs),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _parse(value) ?? TimeOfDay.now(),
            );
            if (picked != null) onChanged(_format(picked));
          },
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: const Icon(Icons.access_time, size: 18),
            ),
            isEmpty: value == null,
            child: value != null ? Text(_display(context, value!)) : null,
          ),
        ),
      ],
    );
  }

  TimeOfDay? _parse(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _format(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _display(BuildContext context, String value) {
    final time = _parse(value);
    if (time == null) return value;
    return time.format(context);
  }
}
