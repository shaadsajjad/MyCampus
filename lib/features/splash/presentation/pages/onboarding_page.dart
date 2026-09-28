import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/theme/text_styles.dart';
import '../cubit/splash_cubit.dart';
import '../widgets/brand_header.dart';
import '../widgets/role_card.dart';
import '../widgets/auth_toggle.dart';
import '../widgets/security_footer.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildRoleSection(context),
              const SizedBox(height: AppTheme.spaceLg),
              _buildContinueButton(context),
              const SizedBox(height: AppTheme.spaceMd),
              BlocBuilder<SplashCubit, SplashState>(
                builder: (context, state) {
                  return AuthToggle(
                    currentMode: state.authMode,
                    onToggle: (mode) =>
                        context.read<SplashCubit>().toggleAuthMode(mode),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceLg),
              const SecurityFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('roles.selectRole'.tr(), style: AppTextStyles.headlineSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm,
                vertical: AppTheme.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'splash.stepOf'.tr(),
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFF264191),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          'splash.chooseAccess'.tr(),
          style: AppTextStyles.bodySm,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            return Column(
              children: [
                RoleCard(
                  role: UserRole.superAdmin,
                  titleKey: 'roles.superAdmin',
                  subtitleKey: 'roles.superAdminDesc',
                  icon: Icons.account_balance,
                  iconBgColor: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.primary,
                  badgeTextKey: 'splash.institutionalAuthority',
                  badgeBgColor: AppColors.surfaceContainer,
                  badgeTextColor: const Color(0xFF264191),
                  badgeDotColor: AppColors.primary,
                  trailingTextKey: 'splash.adminKeyRequired',
                  trailingIcon: Icons.lock,
                  isSelected: state.selectedRole == UserRole.superAdmin,
                  onTap: () =>
                      context.read<SplashCubit>().selectRole(UserRole.superAdmin),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                RoleCard(
                  role: UserRole.faculty,
                  titleKey: 'roles.faculty',
                  subtitleKey: 'roles.facultyDesc',
                  icon: Icons.co_present,
                  iconBgColor: const Color(0xFFFFDCC3),
                  iconColor: const Color(0xFF653400),
                  badgeTextKey: 'splash.academicStaff',
                  badgeBgColor: const Color(0xFFFFDCC3),
                  badgeTextColor: const Color(0xFF6E3900),
                  badgeDotColor: const Color(0xFFFC922B),
                  trailingTextKey: 'splash.facultyIdSync',
                  trailingIcon: Icons.badge,
                  isSelected: state.selectedRole == UserRole.faculty,
                  onTap: () =>
                      context.read<SplashCubit>().selectRole(UserRole.faculty),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                RoleCard(
                  role: UserRole.student,
                  titleKey: 'roles.student',
                  subtitleKey: 'roles.studentDesc',
                  icon: Icons.school,
                  iconBgColor: AppColors.primaryContainer,
                  iconColor: AppColors.onSecondary,
                  badgeTextKey: 'splash.campusStudent',
                  badgeBgColor: AppColors.surfaceContainerHighest,
                  badgeTextColor: const Color(0xFF264191),
                  badgeDotColor: AppColors.secondary,
                  trailingTextKey: 'splash.instantPass',
                  trailingIcon: Icons.qr_code_scanner,
                  isSelected: state.selectedRole == UserRole.student,
                  onTap: () =>
                      context.read<SplashCubit>().selectRole(UserRole.student),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (context, state) {
        final roleName = _getRoleName(state.selectedRole);
        final action = state.authMode == AuthMode.login
            ? 'common.continue'.tr()
            : 'common.register'.tr();
        return ElevatedButton(
          onPressed: () {
            // TODO: Navigate to login/register page
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$action $roleName'),
              const SizedBox(width: AppTheme.spaceSm),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        );
      },
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'roles.superAdmin'.tr();
      case UserRole.faculty:
        return 'roles.faculty'.tr();
      case UserRole.student:
        return 'roles.student'.tr();
    }
  }
}