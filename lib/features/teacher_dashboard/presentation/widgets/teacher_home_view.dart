import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/coming_soon_tab.dart';
import 'package:mycampus/core/widgets/dashboard_shell.dart';
import 'package:mycampus/features/member_profile/presentation/pages/member_profile_page.dart';
import 'package:mycampus/core/domain/entities/notice_audience.dart';
import 'package:mycampus/features/notices/presentation/pages/member_notices_page.dart';
import 'package:mycampus/features/teacher_dashboard/domain/entities/teacher_university.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/sections/academic_telemetry_row.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/sections/announcements_section.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/sections/faculty_id_card.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/sections/faculty_quick_actions.dart';
import 'package:mycampus/features/teacher_dashboard/presentation/widgets/sections/teaching_schedule_section.dart';

/// The approved-faculty home screen, redesigned around the Stitch mock:
/// brand strip header with "Faculty Online" pill, faculty ID card with
/// verified stamp, 2x2 quick-actions bento, 3-stat telemetry row,
/// teaching schedule (imminent + afternoon + office hours), recent
/// announcements with reach-bar, and a lab-status footer.
///
/// All interactive shortcuts (Mark Attendance, Post Notice, Gradebook,
/// Course Materials, Take Attendance, Roster, View Details, Edit
/// Notice, Resend Push, Broadcast New) are no-op stubs today — they
/// live inside the bottom-nav shell so the same shell can later route
/// them to the matching sub-screens.
class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({
    required this.name,
    required this.email,
    required this.university,
    required this.avatarUrl,
    required this.teacherId,
    required this.department,
    required this.designation,
    super.key,
  });

  final String? name;
  final String? email;
  final TeacherUniversity? university;
  final String? avatarUrl;
  final String teacherId;
  final String department;
  final String designation;

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
        _TeacherHomeBody(
          name: name,
          email: email,
          university: university,
          avatarUrl: avatarUrl,
          teacherId: teacherId,
          department: department,
          designation: designation,
        ),
        const ComingSoonTab(
          titleKey: 'common.routine',
          icon: Icons.calendar_today,
        ),
        const MemberNoticesPage(audience: NoticeAudience.faculty),
        const MemberProfilePage(),
      ],
    );
  }
}

class _TeacherHomeBody extends StatelessWidget {
  const _TeacherHomeBody({
    required this.name,
    required this.email,
    required this.university,
    required this.avatarUrl,
    required this.teacherId,
    required this.department,
    required this.designation,
  });

  final String? name;
  final String? email;
  final TeacherUniversity? university;
  final String? avatarUrl;
  final String teacherId;
  final String department;
  final String designation;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.trim().isNotEmpty == true
        ? name!
        : (email ?? 'teacher.dashboard'.tr());

    return Column(
      children: [
        const _BrandHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceXl,
            ),
            children: [
              _GreetingRow(facultyName: displayName),
              const SizedBox(height: AppTheme.spaceMd),
              FacultyIdCard(
                university: university,
                facultyName: displayName,
                department: department,
                facultyId: teacherId,
                avatarUrl: avatarUrl,
                designation: designation,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              FacultyQuickActions(
                onMarkAttendanceTap: _noop,
                onPostNoticeTap: _noop,
                onGradebookTap: _noop,
                onMaterialsTap: _noop,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              AcademicTelemetryRow(
                enrolledCount: 112,
                sectionsCount: 2,
                attendancePercent: 94.2,
                attendanceDelta: '2.1',
                pendingSubmissions: 8,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TeachingScheduleSection(
                onTakeAttendanceTap: _noop,
                onRosterTap: _noop,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              AnnouncementsSection(
                onBroadcastTap: _noop,
                onEditTap: _noop,
                onResendTap: _noop,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              const LabStatusFooter(),
            ],
          ),
        ),
      ],
    );
  }

  void _noop() {}
}

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.facultyName});

  final String facultyName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'teacher.springTerm'.tr().toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'teacher.facultyPortal'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSm + 2,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'teacher.facultyOnline'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sticky brand header rendered above the scrolling content (replaces
/// the old AppBar title so the redesigned dashboards can keep the full
/// gradient/glassy look).
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

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
                    'common.approvedFaculty'.tr(),
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
  const _HeaderIconButton({
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
  const _HeaderAvatarButton({required this.onTap});

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
              width: 1,
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