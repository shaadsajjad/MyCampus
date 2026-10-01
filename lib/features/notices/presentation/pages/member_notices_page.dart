import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/notices/domain/entities/notice.dart';
import 'package:mycampus/features/notices/presentation/cubit/member_notices_cubit.dart';
import 'package:mycampus/features/notices/presentation/widgets/notice_card.dart';

/// The Notices tab inside the student and teacher dashboards — the
/// read-only feed of what the university admin has published, filtered to
/// this viewer's audience (`all` + `students`/`faculty`).
///
/// Embedded as a tab body via `DashboardShell`, so it provides its own
/// [MemberNoticesCubit] the way a page normally would but has no
/// `Scaffold` or bottom nav of its own — those come from the shell.
class MemberNoticesPage extends StatelessWidget {
  const MemberNoticesPage({required this.audience, super.key});

  /// Which role-specific audience to request. `students` for the student
  /// dashboard, `faculty` for the teacher's.
  final NoticeAudience audience;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemberNoticesCubit(audience: audience),
      child: const _MemberNoticesView(),
    );
  }
}

class _MemberNoticesView extends StatelessWidget {
  const _MemberNoticesView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MemberNoticesCubit>();

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: BlocBuilder<MemberNoticesCubit, MemberNoticesState>(
        builder: (context, state) {
          if (state.status == MemberNoticesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MemberNoticesStatus.error) {
            return _ScrollableMessage(
              icon: Icons.cloud_off,
              title: 'notices.loadFailed'.tr(),
              message: state.errorMessage,
              actionLabel: 'profile.retry'.tr(),
              onAction: cubit.load,
            );
          }
          if (state.notices.isEmpty) {
            return const _ScrollableMessage(
              icon: Icons.campaign_outlined,
              titleKey: 'notices.emptyForMembers',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceXl,
            ),
            itemCount: state.notices.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spaceSm),
            itemBuilder: (context, index) {
              // No canDelete / onDelete — members read, admins manage.
              return NoticeCard(notice: state.notices[index]);
            },
          );
        },
      ),
    );
  }
}

/// Shared empty/error layout: stays scrollable so pull-to-refresh keeps
/// working even when there is nothing to show.
class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({
    required this.icon,
    this.title,
    this.titleKey,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String? title;
  final String? titleKey;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = title ?? titleKey?.tr() ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 48, color: textTheme.bodySmall?.color),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      heading,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        message!,
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppTheme.spaceMd),
                      OutlinedButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.refresh),
                        label: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
