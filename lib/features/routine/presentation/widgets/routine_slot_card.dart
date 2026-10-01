import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/features/routine/domain/entities/routine_slot.dart';

/// One period in the weekly timetable. [onDelete] is omitted for the
/// read-only "My Routine" view — mirrors `CourseCard`'s shape.
class RoutineSlotCard extends StatelessWidget {
  const new({
    required this.slot,
    this.isBusy = false,
    this.onDelete,
    super.key,
  });

  final RoutineSlot slot;
  final bool isBusy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppColors.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot.startTime,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.brandAccentText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  slot.endTime,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.brandAccentText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courseCode,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  slot.courseTitle,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slot.room != null || slot.section != null) ...[
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    [slot.room, slot.section].whereType<String>().join(' • '),
                    style: textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'common.delete'.tr(),
              onPressed: isBusy ? null : onDelete,
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
    );
  }
}
