import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/app_image_picker_field.dart' show AppImagePickerField;
import 'package:mycampus/core/widgets/profile_widgets.dart';

/// Top-of-profile identity card shared by every profile screen: avatar,
/// name, email, role + verification badges and an edit affordance. Same
/// navy gradient as the dashboards' ID cards, so the Profile tab and the
/// Home tab read as one design.
///
/// Takes plain values rather than a role-specific entity — the super
/// admin, student and faculty profiles each have their own entity type,
/// and this card is the one place they must look identical.
class ProfileHeaderCard extends StatelessWidget {
  const new({
    required this.displayName,
    required this.email,
    required this.initials,
    required this.roleLabelKey,
    required this.verified,
    this.avatarUrl,
    this.editTooltipKey = 'profile.editName',
    this.onEdit,
    this.onEditAvatar,
    this.isSavingAvatar = false,
    super.key,
  });

  final String displayName;
  final String email;
  final String initials;

  /// Translation key for the role badge (e.g. `roles.superAdmin`).
  final String roleLabelKey;

  final bool verified;
  final String? avatarUrl;

  /// Translation key for the edit button's tooltip. Omit [onEdit] to hide
  /// the button entirely.
  final String editTooltipKey;
  final VoidCallback? onEdit;

  /// Tapping the avatar itself opens the photo picker — a separate
  /// affordance from [onEdit] (which only edits the display name). Omit to
  /// leave the avatar non-interactive (e.g. a read-only context).
  final VoidCallback? onEditAvatar;

  /// Shows a spinner over the avatar instead of the camera badge while an
  /// upload/removal from [onEditAvatar] is in flight.
  final bool isSavingAvatar;

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
              _EditableAvatar(
                avatarUrl: avatarUrl,
                initials: initials,
                onTap: onEditAvatar,
                isSaving: isSavingAvatar,
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: editTooltipKey.tr(),
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
              ProfileBadge(
                icon: _roleIcon,
                label: roleLabelKey.tr(),
                color: Colors.white,
              ),
              ProfileBadge(
                icon: verified ? Icons.verified : Icons.error_outline,
                label: (verified ? 'profile.verified' : 'profile.unverified').tr(),
                color: verified ? Colors.greenAccent : AppColors.onTertiaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Small enough to derive from the label key rather than adding another
  /// parameter every caller has to keep in sync.
  IconData get _roleIcon => switch (roleLabelKey) {
    'roles.superAdmin' => Icons.admin_panel_settings,
    'roles.faculty' => Icons.school_outlined,
    _ => Icons.person_outline,
  };
}

/// [ProfileAvatar] plus a camera badge when [onTap] is set — the same
/// tap-to-pick affordance [AppImagePickerField] uses on the registration
/// forms, scaled down to fit the header card's 64px avatar.
class _EditableAvatar extends StatelessWidget {
  const new({
    required this.avatarUrl,
    required this.initials,
    required this.onTap,
    required this.isSaving,
  });

  final String? avatarUrl;
  final String initials;
  final VoidCallback? onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final avatar = ProfileAvatar(avatarUrl: avatarUrl, initials: initials);
    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (isSaving)
            const Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 11,
                  color: AppColors.onSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
