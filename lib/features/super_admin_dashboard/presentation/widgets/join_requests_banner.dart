import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

/// Shown on the dashboard only when there's at least one pending join
/// request — an empty state here would just be dead weight ("review your 0
/// requests" is not an action anyone takes).
class JoinRequestsBanner extends StatelessWidget {
  const JoinRequestsBanner({
    required this.pendingCount,
    required this.onReview,
    super.key,
  });

  final int pendingCount;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.tertiary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pending_actions,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'admin.joinRequestsAwaiting'.tr(
                    namedArgs: {'count': '$pendingCount'},
                  ),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text('admin.joinRequestsDesc'.tr(), style: textTheme.bodySmall),
                const SizedBox(height: AppTheme.spaceMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text('admin.reviewJoinRequests'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
