import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/notices/presentation/cubit/notices_cubit.dart';
import 'package:mycampus/features/notices/presentation/widgets/compose_notice_sheet.dart';
import 'package:mycampus/features/notices/presentation/widgets/notice_card.dart';

/// The super admin's "Notices" tab — post announcements for their
/// university and manage the ones they've already posted. Embedded as a
/// tab body (via `SuperAdminDashboardPage`'s bottom nav), not a standalone
/// route, so it provides its own [NoticesCubit] the same way a page
/// normally would.
class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoticesCubit(),
      child: const _NoticesView(),
    );
  }
}

class _NoticesView extends StatelessWidget {
  const _NoticesView();

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
            child: Builder(
              builder: (context) {
                if (state.status == NoticesStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == NoticesStatus.error) {
                  return _ErrorState(
                    message: state.errorMessage,
                    onRetry: cubit.load,
                  );
                }
                if (state.notices.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    AppTheme.spaceMd,
                    AppTheme.spaceXl * 2,
                  ),
                  itemCount: state.notices.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppTheme.spaceSm),
                  itemBuilder: (context, index) {
                    final notice = state.notices[index];
                    return NoticeCard(
                      notice: notice,
                      canDelete: notice.authorId == state.currentUserId,
                      isDeleting: state.deletingIds.contains(notice.id),
                      onDelete: () => cubit.deleteNotice(notice.id),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              ),
            ),
          ),
        );
      },
    );
  }
}
