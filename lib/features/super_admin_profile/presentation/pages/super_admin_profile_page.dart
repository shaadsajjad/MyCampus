import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/theme_cubit.dart';
import 'package:mycampus/core/widgets/language_picker.dart';
import 'package:mycampus/core/widgets/profile_header_card.dart';
import 'package:mycampus/core/widgets/profile_widgets.dart';
import 'package:mycampus/features/super_admin_profile/domain/entities/super_admin_profile.dart';
import 'package:mycampus/features/super_admin_profile/presentation/cubit/super_admin_profile_cubit.dart';
import 'package:mycampus/features/super_admin_profile/presentation/widgets/edit_name_sheet.dart';

/// The super admin's "Profile" tab — their account, the institution they
/// own, appearance and security settings. Embedded as a tab body of
/// `SuperAdminDashboardPage`, so it provides its own Cubit like a page but
/// has no `Scaffold` of its own.
class SuperAdminProfilePage extends StatelessWidget {
  const SuperAdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuperAdminProfileCubit(),
      child: const _SuperAdminProfileView(),
    );
  }
}

class _SuperAdminProfileView extends StatelessWidget {
  const _SuperAdminProfileView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperAdminProfileCubit>();

    return BlocConsumer<SuperAdminProfileCubit, SuperAdminProfileState>(
      listenWhen: (previous, current) => previous.outcome != current.outcome,
      listener: (context, state) {
        switch (state.outcome) {
          case ProfileOutcome.nameSaved:
            _showSnack(context, 'profile.nameSaved'.tr());
          case ProfileOutcome.resetEmailSent:
            _showSnack(
              context,
              'profile.resetEmailSent'.tr(
                namedArgs: {'email': state.profile?.email ?? ''},
              ),
            );
          case ProfileOutcome.resetEmailFailed:
            _showSnack(
              context,
              state.errorMessage ?? 'profile.resetEmailFailed'.tr(),
              isError: true,
            );
          case ProfileOutcome.loggedOut:
            context.go(AppRoute.onboarding);
          // Shown inline in the edit sheet instead.
          case ProfileOutcome.nameSaveFailed:
          case null:
            break;
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return state.status == ProfileStatus.error
              ? _ErrorState(message: state.errorMessage, onRetry: cubit.load)
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
                roleLabelKey: 'roles.superAdmin',
                verified: profile.verified,
                onEdit: () => showEditNameSheet(context),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              if (profile.university != null) ...[
                _InstitutionSection(university: profile.university!),
                const SizedBox(height: AppTheme.spaceLg),
              ],
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

class _InstitutionSection extends StatelessWidget {
  const _InstitutionSection({required this.university});

  final ProfileUniversity university;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notSet = 'profile.notSet'.tr();
    final location = [
      university.city,
      university.country,
    ].whereType<String>().join(', ');
    final established = university.establishedAt;

    return ProfileSection(
      title: 'profile.institution'.tr(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Row(
            children: [
              ProfileUniversityLogo(logoUrl: university.logoUrl),
              const SizedBox(width: AppTheme.spaceSm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      university.shortName,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ProfileInfoRow(
          icon: Icons.category_outlined,
          label: 'admin.universityType'.tr(),
          value: university.type?.labelKey.tr() ?? notSet,
        ),
        ProfileInfoRow(
          icon: Icons.location_on_outlined,
          label: 'profile.location'.tr(),
          value: location.isEmpty ? notSet : location,
        ),
        ProfileInfoRow(
          icon: Icons.event_outlined,
          label: 'profile.established'.tr(),
          value: established == null
              ? notSet
              : DateFormat.yMMMM().format(established),
        ),
        ProfileInfoRow(
          icon: Icons.tag,
          label: 'admin.campusId'.tr(),
          value: university.id,
          trailing: Icon(
            Icons.content_copy,
            size: 18,
            color: theme.colorScheme.outline,
          ),
          onTap: () {
            unawaited(Clipboard.setData(ClipboardData(text: university.id)));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('admin.campusIdCopied'.tr())),
              );
          },
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.profile});

  final SuperAdminProfile profile;

  @override
  Widget build(BuildContext context) {
    final memberSince = profile.memberSince;
    return ProfileSection(
      title: 'profile.account'.tr(),
      children: [
        ProfileInfoRow(
          icon: Icons.mail_outline,
          label: 'common.email'.tr(),
          value: profile.email,
        ),
        ProfileInfoRow(
          icon: Icons.calendar_month_outlined,
          label: 'profile.memberSince'.tr(),
          value: memberSince == null
              ? 'profile.notSet'.tr()
              : DateFormat.yMMMd().format(memberSince),
        ),
        ProfileInfoRow(
          icon: Icons.shield_outlined,
          label: 'profile.accountStatus'.tr(),
          value: 'status.approved'.tr(),
          valueColor: AppColors.success,
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return ProfileSection(
          title: 'profile.preferences'.tr(),
          children: [
            ProfileInfoRow(
              icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
              label: 'profile.darkModeDesc'.tr(),
              value: 'profile.darkMode'.tr(),
              trailing: Switch(
                value: isDark,
                onChanged: (value) => context.read<ThemeCubit>().setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ),
            const LanguagePreferenceRow(),
          ],
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      ProfileErrorState(message: message, onRetry: onRetry);
}
