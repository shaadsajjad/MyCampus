import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// A titled card grouping related profile rows, separated by dividers.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spaceXs,
            bottom: AppTheme.spaceSm,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppColors.shadowSm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 56, height: 1),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single icon + label + value row inside a [ProfileSection]. Tappable
/// when [onTap] is set; [trailing] replaces the default chevron.
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailingWidget =
        trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: theme.colorScheme.outline)
            : null);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMd,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppTheme.spaceSm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  if (value != null)
                    Text(
                      value!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: valueColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: AppTheme.spaceSm),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}
