import 'package:flutter/material.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/theme/app_colors.dart';

/// Icon + its container color for a `RoleCard`.
class RoleIconStyle {
  const RoleIconStyle({
    required this.icon,
    required this.backgroundColor,
    required this.color,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color color;
}

/// The small status pill (dot + label) shown at the bottom of a `RoleCard`.
class RoleBadge {
  const RoleBadge({
    required this.textKey,
    required this.backgroundColor,
    required this.textColor,
    required this.dotColor,
  });

  final String textKey;
  final Color backgroundColor;
  final Color textColor;
  final Color dotColor;
}

/// The display data for a single `RoleCard` — copy keys plus the icon and
/// badge styling for one [UserRole]. Keeping this as a model (rather than
/// passing a dozen loose parameters into the widget) lets `kRoleOptions`
/// describe all selectable roles as plain data instead of three
/// near-duplicate widget blocks.
class RoleOption {
  const RoleOption({
    required this.role,
    required this.titleKey,
    required this.subtitleKey,
    required this.trailingTextKey,
    required this.iconStyle,
    required this.badge,
    this.trailingIcon,
  });

  final UserRole role;
  final String titleKey;
  final String subtitleKey;
  final String trailingTextKey;
  final RoleIconStyle iconStyle;
  final RoleBadge badge;
  final IconData? trailingIcon;
}

/// The roles offered on the onboarding screen, in display order.
const kRoleOptions = [
  RoleOption(
    role: UserRole.superAdmin,
    titleKey: 'roles.superAdmin',
    subtitleKey: 'roles.superAdminDesc',
    trailingTextKey: 'splash.adminKeyRequired',
    trailingIcon: Icons.lock,
    iconStyle: RoleIconStyle(
      icon: Icons.account_balance,
      backgroundColor: AppColors.surfaceContainerHigh,
      color: AppColors.primary,
    ),
    badge: RoleBadge(
      textKey: 'splash.institutionalAuthority',
      backgroundColor: AppColors.surfaceContainer,
      textColor: AppColors.brandAccentText,
      dotColor: AppColors.primary,
    ),
  ),
  RoleOption(
    role: UserRole.faculty,
    titleKey: 'roles.faculty',
    subtitleKey: 'roles.facultyDesc',
    trailingTextKey: 'splash.facultyIdSync',
    trailingIcon: Icons.badge,
    iconStyle: RoleIconStyle(
      icon: Icons.co_present,
      backgroundColor: Color(0xFFFFDCC3),
      color: Color(0xFF653400),
    ),
    badge: RoleBadge(
      textKey: 'splash.academicStaff',
      backgroundColor: Color(0xFFFFDCC3),
      textColor: Color(0xFF6E3900),
      dotColor: Color(0xFFFC922B),
    ),
  ),
  RoleOption(
    role: UserRole.student,
    titleKey: 'roles.student',
    subtitleKey: 'roles.studentDesc',
    trailingTextKey: 'splash.instantPass',
    trailingIcon: Icons.qr_code_scanner,
    iconStyle: RoleIconStyle(
      icon: Icons.school,
      backgroundColor: AppColors.primaryContainer,
      color: AppColors.onSecondary,
    ),
    badge: RoleBadge(
      textKey: 'splash.campusStudent',
      backgroundColor: AppColors.surfaceContainerHighest,
      textColor: AppColors.brandAccentText,
      dotColor: AppColors.secondary,
    ),
  ),
];
