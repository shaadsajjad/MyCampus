import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Centered "couldn't load" state with a retry action, shared by every
/// profile screen. Stays scrollable so pull-to-refresh keeps working.
class ProfileErrorState extends StatelessWidget {
  const ProfileErrorState({this.message, required this.onRetry, super.key});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'profile.loadFailed'.tr(),
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                message!,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppTheme.spaceMd),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('profile.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled card grouping related profile rows, separated by dividers.
///
/// Lives in `core/widgets` rather than any one feature because all three
/// profile screens (super admin, student, faculty) render the same
/// section/row rhythm — keeping one implementation is what makes the
/// tabs look identical across roles.
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

/// Square university logo with a monogram fallback — used by the Campus
/// section on every profile screen.
class ProfileUniversityLogo extends StatelessWidget {
  const ProfileUniversityLogo({required this.logoUrl, super.key});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    const fallback = ColoredBox(
      color: AppColors.primaryContainer,
      child: Center(
        child: Icon(Icons.account_balance, color: Colors.white, size: 26),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: SizedBox.square(
        dimension: 52,
        child: logoUrl == null
            ? fallback
            : Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

/// Round avatar with an initials fallback, framed for the navy gradient
/// header card.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.avatarUrl, required this.initials, super.key});

  final String? avatarUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: avatarUrl == null
            ? ProfileInitials(initials: initials)
            : Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ProfileInitials(initials: initials),
              ),
      ),
    );
  }
}

class ProfileInitials extends StatelessWidget {
  const ProfileInitials({required this.initials, super.key});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainerHighest,
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Small translucent pill used for the role + verification badges under
/// the header card's name.
class ProfileBadge extends StatelessWidget {
  const ProfileBadge({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
