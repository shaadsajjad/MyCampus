import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/field_label.dart';

/// A labeled [TextFormField] bound to a Cubit's state — no local widget
/// state; the current value flows in via [initialValue] and out via
/// [onChanged].
class AppTextField extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    this.isRequired = true,
    this.keyboardType,
    this.validator,
    this.hint,
    super.key,
  });

  final String label;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: AppTheme.spaceXs),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}
