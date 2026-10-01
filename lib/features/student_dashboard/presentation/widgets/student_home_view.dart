import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/domain/entities/notice_audience.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/coming_soon_tab.dart';
import 'package:mycampus/core/widgets/dashboard_shell.dart';
import 'package:mycampus/features/member_profile/presentation/pages/member_profile_page.dart';
import 'package:mycampus/features/notices/presentation/pages/member_notices_page.dart';
import 'package:mycampus/features/student_dashboard/domain/entities/student_university.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/academic_tools_bento.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/access_pill_bar.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/attendance_progress_card.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/bulletins_section.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/digital_id_card.dart';
import 'package:mycampus/features/student_dashboard/presentation/widgets/sections/todays_schedule_section.dart';

/// The approved-student home screen, redesigned around the Stitch mock:
/// brand strip header, verified-pill bar, digital ID card, 2x2 academic
/// tools bento, attendance progress with circular meter + breakdown
/// bars, today's schedule with current/up-next cards, and bulletins.
///
/// All interactive shortcuts (Routine, Check-In, Gradebook, Services,
/// Submit Beacon, Notes, View All Notices, Download Hall Ticket) are
/// currently no-op stubs that route to the matching "coming soon"
/// placeholder tab inside the bottom-nav shell.
class StudentHomeView extends StatelessWidget {
  const new({
    required this.name,
    required this.email,
    required this.university,
    required this.avatarUrl,
    required this.studentId,
    required this.program,
    super.key,
  });

  final String? name;
  final String? email;
  final StudentUniversity? university;
  final String? avatarUrl;
  final String studentId;
  final String program;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      initialIndex: 0,
      navItems: const [
        DashboardNavItem(icon: Icons.grid_view, labelKey: 'common.home'),
        DashboardNavItem(icon: Icons.calendar_today, labelKey: 'common.routine'),
        DashboardNavItem(icon: Icons.campaign, labelKey: 'common.notices'),
        DashboardNavItem(
          icon: Icons.account_circle,
          labelKey: 'common.profile',
        ),
      ],
      tabs: [
        _StudentHomeBody(
          name: name,
          email: email,
          university: university,
          avatarUrl: avatarUrl,
          studentId: studentId,
          program: program,
        ),
        const ComingSoonTab(
          titleKey: 'common.routine',
          icon: Icons.calendar_today,
        ),
        const MemberNoticesPage(audience: NoticeAudience.students),
        const MemberProfilePage(),
      ],
    );
  }
}

class _StudentHomeBody extends StatelessWidget {
  const new({
    required this.name,
    required this.email,
    required this.university,
    required this.avatarUrl,
    required this.studentId,
    required this.program,
  });

  final String? name;
  final String? email;
  final StudentUniversity? university;
  final String? avatarUrl;
  final String studentId;
  final String program;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.trim().isNotEmpty == true
        ? name!
        : (email ?? 'student.dashboard'.tr());
    final programText = program.trim().isEmpty
        ? (university?.shortName ?? 'student.dashboard'.tr())
        : program;

    return Column(
      children: [
        const _BrandHeader(
          subtitleKey: 'common.approvedAndVerified',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceXl,
            ),
            children: [
              AccessPillBar(
                universityName: university?.shortName ?? 'Campus',
              ),
              const SizedBox(height: AppTheme.spaceLg),
              DigitalIdCard(
                university: university,
                studentName: displayName,
                program: programText,
                studentId: studentId,
                avatarUrl: avatarUrl,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              AcademicToolsBento(
                onRoutineTap: _noop,
                onCheckInTap: _noop,
                onResultsTap: _noop,
                onServicesTap: _noop,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              const AttendanceProgressCard(),
              const SizedBox(height: AppTheme.spaceLg),
              TodaysScheduleSection(
                onSubmitBeacon: _noop,
                onOpenNotes: _noop,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              const BulletinsSection(),
            ],
          ),
        ),
      ],
    );
  }

  void _noop() {}
}

/// Sticky brand header rendered above the scrolling content (replaces
/// the old AppBar title so the redesigned dashboards can keep the full
/// gradient/glassy look).
class _BrandHeader extends StatelessWidget {
  const new({required this.subtitleKey});

  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceSm,
        AppTheme.spaceMd,
        AppTheme.spaceSm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.brandTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.school,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MyCampus',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitleKey.tr(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.notifications,
              onTap: _noop,
              showDot: true,
            ),
            const SizedBox(width: AppTheme.spaceXs),
            _HeaderAvatarButton(onTap: _noop),
          ],
        ),
      ),
    );
  }

  void _noop() {}
}

class _HeaderIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.onSurfaceVariant),
            if (showDot)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAvatarButton extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}