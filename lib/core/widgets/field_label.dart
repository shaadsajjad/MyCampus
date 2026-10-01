import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';

/// A form field label with an optional red "required" asterisk.
class FieldLabel extends StatelessWidget {
  const new({required this.label, this.isRequired = true, super.key});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.labelMedium),
        if (isRequired) ...[
          const SizedBox(width: 2),
          Text(
            '*',
            style: textTheme.labelMedium?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
