import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Icon-badge + title + description header, used at the top of a
/// list-style admin tab. Promoted to `core/` once three features
/// (`courses`, `member_directory`, `notices`) needed the identical
/// title/description/icon-badge rhythm — see `clean_architecture.md`'s
/// `core/` promotion rule ("duplicating a widget across two features is
/// the signal to promote it").
class SectionHeader extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Optional content below the description — a stat line, a button, etc.
  final Widget? trailing;

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
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(description, style: textTheme.bodySmall),
              if (trailing != null) ...[
                const SizedBox(height: AppTheme.spaceXs),
                trailing!,
              ],
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
          child: Icon(icon, color: AppColors.primary),
        ),
      ],
    );
  }
}
