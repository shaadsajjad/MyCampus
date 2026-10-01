import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/theme_cubit.dart';
import 'package:mycampus/core/widgets/avatar_editor.dart';
import 'package:mycampus/core/widgets/edit_name_sheet_body.dart';
import 'package:mycampus/core/widgets/language_picker.dart';
import 'package:mycampus/core/widgets/profile_header_card.dart';
import 'package:mycampus/core/widgets/profile_widgets.dart';
import 'package:mycampus/features/member_profile/domain/entities/member_profile.dart';
import 'package:mycampus/features/member_profile/presentation/cubit/member_profile_cubit.dart';

/// The student / faculty "Profile" tab — their account, the campus they
/// belong to, their enrollment, appearance and security settings.
///
/// Mirrors `SuperAdminProfilePage` section for section (header card →
/// campus → account → preferences → security → logout) so all three role
/// tabs read as the same screen; the difference is the middle "Academic"
/// section, which is role-specific.
class MemberProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemberProfileCubit(),
      child: const _MemberProfileView(),
    );
  }
}

class _MemberProfileView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemberProfileCubit>();

    return BlocConsumer<MemberProfileCubit, MemberProfileState>(
      listenWhen: (previous, current) => previous.outcome != current.outcome,
      listener: (context, state) {
        switch (state.outcome) {
          case MemberProfileOutcome.nameSaved:
            _showSnack(context, 'profile.nameSaved'.tr());
          case MemberProfileOutcome.avatarSaved:
            _showSnack(context, 'profile.nameSaved'.tr());
          case MemberProfileOutcome.avatarSaveFailed:
            _showSnack(
              context,
              state.errorMessage ?? 'common.error'.tr(),
              isError: true,
            );
          case MemberProfileOutcome.resetEmailSent:
            _showSnack(
              context,
              'profile.resetEmailSent'.tr(
                namedArgs: {'email': state.profile?.email ?? ''},
              ),
            );
          case MemberProfileOutcome.resetEmailFailed:
            _showSnack(
              context,
              state.errorMessage ?? 'profile.resetEmailFailed'.tr(),
              isError: true,
            );
          case MemberProfileOutcome.loggedOut:
            context.go(AppRoute.onboarding);
          // Shown inline in the edit sheet instead.
          case MemberProfileOutcome.nameSaveFailed:
          case null:
            break;
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return state.status == MemberProfileStatus.error
              ? ProfileErrorState(
                  message: state.errorMessage,
                  onRetry: cubit.load,
                )
              : const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            children: [
              ProfileHeaderCard(
                displayName: profile.displayName,
                email: profile.email,
                initials: profile.initials,
                avatarUrl: profile.avatarUrl,
                roleLabelKey: profile.roleLabelKey,
                verified: profile.verified,
                onEdit: () => _openEditNameSheet(context),
                isSavingAvatar: state.isSavingAvatar,
                onEditAvatar: () => pickAndApplyAvatar(
                  context,
                  hasAvatar: profile.avatarUrl != null,
                  onPicked: cubit.updateAvatar,
                  onRemove: cubit.removeAvatar,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              _CampusSection(campus: profile.campus, status: profile.status),
              const SizedBox(height: AppTheme.spaceLg),
              _AcademicSection(profile: profile),
              const SizedBox(height: AppTheme.spaceLg),
              _AccountSection(profile: profile),
              const SizedBox(height: AppTheme.spaceLg),
              const _PreferencesSection(),
              const SizedBox(height: AppTheme.spaceLg),
              ProfileSection(
                title: 'profile.security'.tr(),
                children: [
                  ProfileInfoRow(
                    icon: Icons.lock_reset,
                    label: 'profile.changePasswordDesc'.tr(),
                    value: 'profile.changePassword'.tr(),
                    onTap: state.isSendingReset
                        ? null
                        : cubit.requestPasswordReset,
                    trailing: state.isSendingReset
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceLg),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: cubit.logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.error.withValues(alpha: 0.06),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text('common.logout'.tr()),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        );
      },
    );
  }

  /// Opens the shared [EditNameSheetBody] from this page's own cubit — the
  /// same widget the super admin's sheet renders, so all three sheets stay
  /// identical without `core` depending on any feature's cubit type.
  void _openEditNameSheet(BuildContext context) {
    final cubit = context.read<MemberProfileCubit>()..startEditingName();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const _EditNameSheet()),
    );
  }

  void _showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : null,
        ),
      );
  }
}

class _EditNameSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemberProfileCubit>();

    return BlocConsumer<MemberProfileCubit, MemberProfileState>(
      listenWhen: (previous, current) => previous.outcome != current.outcome,
      listener: (context, state) {
        if (state.outcome == MemberProfileOutcome.nameSaved) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) => EditNameSheetBody(
        formKey: cubit.nameFormKey,
        value: state.nameDraft,
        isSaving: state.isSavingName,
        errorMessage: state.outcome == MemberProfileOutcome.nameSaveFailed
            ? state.errorMessage
            : null,
        onChanged: cubit.nameDraftChanged,
        onSave: cubit.saveName,
      ),
    );
  }
}

/// Which campus they belong to and where they stand with it. Always
/// rendered — with no campus yet it becomes the "not a member yet" prompt,
/// which is more useful than hiding the section entirely.
class _CampusSection extends StatelessWidget {
  const new({required this.campus, required this.status});

  final MemberCampus? campus;
  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    if (campus == null) {
      return ProfileSection(
        title: 'profile.campus'.tr(),
        children: [
          ProfileInfoRow(
            icon: Icons.account_balance_outlined,
            label: 'profile.notEnrolled'.tr(),
            value: status.labelKey.tr(),
            valueColor: _statusColor,
          ),
        ],
      );
    }

    final location = [
      campus!.city,
      campus!.country,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return ProfileSection(
      title: 'profile.campus'.tr(),
      children: [
        ProfileInfoRow(
          icon: Icons.account_balance,
          label: 'profile.institution'.tr(),
          value: campus!.name,
          trailing: ProfileUniversityLogo(logoUrl: campus!.logoUrl),
        ),
        if (location.isNotEmpty)
          ProfileInfoRow(
            icon: Icons.location_on_outlined,
            label: 'profile.location'.tr(),
            value: location,
          ),
        if (campus!.type != null)
          ProfileInfoRow(
            icon: Icons.workspaces_outline,
            label: 'profile.institutionType'.tr(),
            value: campus!.type!.labelKey.tr(),
          ),
      ],
    );
  }

  Color get _statusColor => switch (status) {
    MemberStatus.approved => AppColors.success,
    MemberStatus.pending => AppColors.secondary,
    MemberStatus.rejected => AppColors.error,
    MemberStatus.none => AppColors.onSurfaceVariant,
  };
}

/// Role-specific enrollment: student id / department / batch for a
/// student, employee id / department / designation for faculty. Renders a
/// "not on file" row rather than disappearing if the role-extension record
/// hasn't been created.
class _AcademicSection extends StatelessWidget {
  const new({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final student = profile.student;
    final teacher = profile.teacher;
    final isStudent = profile.role == UserRole.student;

    if (isStudent && student != null) {
      return ProfileSection(
        title: 'profile.academic'.tr(),
        children: [
          ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'student.studentId'.tr(),
            value: student.studentId,
          ),
          ProfileInfoRow(
            icon: Icons.school_outlined,
            label: 'profile.department'.tr(),
            value: student.department,
          ),
          ProfileInfoRow(
            icon: Icons.calendar_today,
            label: 'student.batch'.tr(),
            value: student.batch,
          ),
        ],
      );
    }

    if (!isStudent && teacher != null) {
      return ProfileSection(
        title: 'profile.academic'.tr(),
        children: [
          ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'teacher.teacherId'.tr(),
            value: teacher.teacherId,
          ),
          ProfileInfoRow(
            icon: Icons.school_outlined,
            label: 'profile.department'.tr(),
            value: teacher.department,
          ),
          ProfileInfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'profile.designation'.tr(),
            value: teacher.designation,
          ),
        ],
      );
    }

    return ProfileSection(
      title: 'profile.academic'.tr(),
      children: [
        ProfileInfoRow(
          icon: Icons.school_outlined,
          label: 'profile.academicNotOnFile'.tr(),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const new({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    // `intl` isn't a dependency yet; `MaterialLocalizations` already
    // provides the app's configured short-date format, so use that rather
    // than hand-rolling a format that ignores the user's locale.
    final localizations = MaterialLocalizations.of(context);
    return ProfileSection(
      title: 'profile.account'.tr(),
      children: [
        ProfileInfoRow(
          icon: Icons.alternate_email,
          label: 'common.email'.tr(),
          value: profile.email,
        ),
        if (profile.phone != null)
          ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'common.phone'.tr(),
            value: profile.phone,
          ),
        ProfileInfoRow(
          icon: Icons.how_to_reg_outlined,
          label: 'profile.accountStatus'.tr(),
          value: profile.status.labelKey.tr(),
          valueColor: switch (profile.status) {
            MemberStatus.approved => AppColors.success,
            MemberStatus.pending => AppColors.secondary,
            MemberStatus.rejected => AppColors.error,
            MemberStatus.none => AppColors.onSurfaceVariant,
          },
        ),
        if (profile.memberSince != null)
          ProfileInfoRow(
            icon: Icons.calendar_month,
            label: 'profile.memberSince'.tr(),
            value: localizations.formatShortDate(profile.memberSince!),
          ),
        if (profile.campus?.shortName.isNotEmpty == true)
          ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'profile.campusId'.tr(),
            value: profile.campus!.shortName,
          ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return ProfileSection(
          title: 'profile.preferences'.tr(),
          children: [
            ProfileInfoRow(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              label: 'profile.darkModeDesc'.tr(),
              value: isDark
                  ? 'profile.darkModeOn'.tr()
                  : 'profile.darkModeOff'.tr(),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              ),
            ),
            const LanguagePreferenceRow(),
          ],
        );
      },
    );
  }
}
