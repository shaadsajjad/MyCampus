import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/field_label.dart';

/// A labeled password [TextFormField] with a visibility toggle. The
/// obscure/visible state is owned by the caller's Cubit (via [obscureText]
/// and [onToggleObscure]) rather than local widget state.
class AppPasswordField extends StatelessWidget {
  const new({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.obscureText,
    required this.onToggleObscure,
    this.validator,
    this.hint,
    super.key,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final String? Function(String?)? validator;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),
        const SizedBox(height: AppTheme.spaceXs),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          obscureText: obscureText,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
