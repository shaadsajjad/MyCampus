import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/super_admin_profile/domain/entities/super_admin_profile.dart';

/// Top-of-profile identity card: avatar, name, email, role + verification
/// badges. Same navy gradient as the dashboard's campus pass card so the
/// two tabs read as one design.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.profile,
    required this.onEdit,
    super.key,
  });

  final SuperAdminProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF213145)],
        ),
        boxShadow: AppColors.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(profile: profile),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'profile.editName'.tr(),
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            children: [
              _Badge(
                icon: Icons.admin_panel_settings,
                label: 'roles.superAdmin'.tr(),
                color: Colors.white,
              ),
              _Badge(
                icon: profile.verified ? Icons.verified : Icons.error_outline,
                label:
                    (profile.verified
                            ? 'profile.verified'
                            : 'profile.unverified')
                        .tr(),
                color: profile.verified
                    ? Colors.greenAccent
                    : AppColors.onTertiaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final SuperAdminProfile profile;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl;
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
            ? _Initials(initials: profile.initials)
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _Initials(initials: profile.initials),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});

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

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

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
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
