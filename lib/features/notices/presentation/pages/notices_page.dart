import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/section_header.dart';
import 'package:mycampus/features/notices/presentation/cubit/notices_cubit.dart';
import 'package:mycampus/features/notices/presentation/widgets/compose_notice_sheet.dart';
import 'package:mycampus/features/notices/presentation/widgets/notice_card.dart';

/// The super admin's "Notices" tab — post announcements for their
/// university and manage the ones they've already posted. Embedded as a
/// tab body (via `SuperAdminDashboardPage`'s bottom nav), not a standalone
/// route, so it provides its own [NoticesCubit] the same way a page
/// normally would.
class NoticesPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticesCubit(),
      child: const _NoticesView(),
    );
  }
}

class _NoticesView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NoticesCubit>();

    return BlocBuilder<NoticesCubit, NoticesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await showComposeNoticeSheet(context);
              if (created ?? false) await cubit.load();
            },
            icon: const Icon(Icons.add),
            label: Text('notices.newNotice'.tr()),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceMd,
                AppTheme.spaceXl * 2,
              ),
              children: [
                SectionHeader(
                  icon: Icons.campaign_outlined,
                  title: 'common.notices'.tr(),
                  description: 'notices.desc'.tr(),
                  trailing: state.status == NoticesStatus.ready
                      ? Text(
                          'notices.summary'.tr(
                            namedArgs: {'count': '${state.notices.length}'},
                          ),
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      : null,
                ),
                const SizedBox(height: AppTheme.spaceMd),
                if (state.status == NoticesStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == NoticesStatus.error)
                  _ErrorState(message: state.errorMessage, onRetry: cubit.load)
                else if (state.notices.isEmpty)
                  const _EmptyState()
                else
                  Column(
                    children: [
                      for (final notice in state.notices) ...[
                        NoticeCard(
                          notice: notice,
                          canDelete: notice.authorId == state.currentUserId,
                          isDeleting: state.deletingIds.contains(notice.id),
                          onDelete: () => cubit.deleteNotice(notice.id),
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
}

class _EmptyState extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'notices.empty'.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const new({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

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
          Text(
            'notices.loadFailed'.tr(),
            style: textTheme.titleMedium,
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
          const SizedBox(height: AppTheme.spaceMd),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text('profile.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
