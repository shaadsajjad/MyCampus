import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/courses/domain/entities/course.dart';
import 'package:mycampus/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:mycampus/features/courses/presentation/widgets/compose_course_sheet.dart';
import 'package:mycampus/features/courses/presentation/widgets/course_card.dart';

/// The super admin's "Courses" tab — the course catalogue their university
/// teaches, which a routine gets built out of later. Embedded as a tab body
/// (via `SuperAdminDashboardPage`'s bottom nav), not a standalone route, so
/// it provides its own [CoursesCubit] the same way a page normally would.
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoursesCubit(),
      child: const _CoursesView(),
    );
  }
}

class _CoursesView extends StatelessWidget {
  const _CoursesView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoursesCubit>();

    return BlocConsumer<CoursesCubit, CoursesState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await ComposeCourseSheet.show(context);
              // The sheet owns its own Cubit; the list only reloads once
              // it's told the write actually landed.
              if (created == true) await cubit.load();
            },
            icon: const Icon(Icons.add),
            label: Text('courses.addCourse'.tr()),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                80,
              ),
              children: [
                _Header(
                  courseCount: state.courses.length,
                  totalCredits: state.totalCredits,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _SearchField(onChanged: cubit.search),
                const SizedBox(height: AppTheme.spaceMd),
                if (state.status == CoursesStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == CoursesStatus.error)
                  _ErrorState(message: state.errorMessage ?? '')
                else if (state.visibleCourses.isEmpty)
                  _EmptyState(hasQuery: state.query.trim().isNotEmpty)
                else
                  Column(
                    children: [
                      for (final course in state.visibleCourses) ...[
                        CourseCard(
                          course: course,
                          isBusy: state.pendingDeleteIds.contains(course.id),
                          onDelete: () => _confirmDelete(context, course),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Deleting a course is destructive and, once routines exist, will break
  /// published timetables that reference it — so it goes through a
  /// confirmation rather than firing on the first tap.
  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final cubit = context.read<CoursesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('courses.deleteTitle'.tr()),
        content: Text(
          'courses.deleteBody'.tr(
            namedArgs: {'code': course.code, 'title': course.title},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete(course.id);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.courseCount, required this.totalCredits});

  final int courseCount;
  final int totalCredits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'courses.title'.tr(),
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text('courses.desc'.tr(), style: textTheme.bodySmall),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'courses.summary'.tr(
                  namedArgs: {
                    'courses': '$courseCount',
                    'credits': '$totalCredits',
                  },
                ),
                style: textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'courses.search'.tr(),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.menu_book_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            hasQuery ? 'courses.noResults'.tr() : 'courses.noCourses'.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
