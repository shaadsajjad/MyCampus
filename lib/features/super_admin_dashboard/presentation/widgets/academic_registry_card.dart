import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/core/widgets/profile_widgets.dart';

/// Direct, one-tap links to the two campus-registry builders (Courses,
/// Routine) from the Home tab. Both are **pushed routes**, not bottom-nav
/// tabs — the bar is already full at 5 items — and this card is their one
/// entry point: neither the Directory tab nor the Courses page link to the
/// other anymore, so there's exactly one path to each, not three.
///
/// Reuses `ProfileSection`/`ProfileInfoRow` (`core/widgets/profile_widgets.dart`)
/// rather than a bespoke card — the icon-badge/label/chevron row is already
/// shared, generic, and exactly this shape.
class AcademicRegistryCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'admin.academicRegistry'.tr(),
      children: [
        ProfileInfoRow(
          icon: Icons.menu_book,
          label: 'courses.navCourses'.tr(),
          value: 'admin.manageCoursesDesc'.tr(),
          onTap: () => context.push(AppRoute.courses),
        ),
        ProfileInfoRow(
          icon: Icons.calendar_today,
          label: 'routine.title'.tr(),
          value: 'admin.manageRoutineDesc'.tr(),
          onTap: () => context.push(AppRoute.routine),
        ),
      ],
    );
  }
}
