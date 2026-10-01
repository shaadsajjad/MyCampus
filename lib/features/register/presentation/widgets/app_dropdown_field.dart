import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/field_label.dart';

/// A labeled [DropdownButtonFormField] bound to a Cubit's state.
class AppDropdownField<T> extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    super.key,
  });

  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),
        const SizedBox(height: AppTheme.spaceXs),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(
                value: item,
                child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
          validator: (v) => v == null ? 'validation.required'.tr() : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
