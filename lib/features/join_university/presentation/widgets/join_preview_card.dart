import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';
import 'package:mycampus/core/widgets/primary_action_button.dart';
import 'package:mycampus/features/join_university/domain/entities/university_preview.dart';

/// Confirmation card shown once a scanned/typed code resolves to a real
/// university — "yes, this is where I want to send a join request".
class JoinPreviewCard extends StatelessWidget {
  const JoinPreviewCard({
    required this.preview,
    required this.isSubmitting,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final UniversityPreview preview;
  final bool isSubmitting;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final location = [
      preview.city,
      preview.country,
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'joinUniversity.confirmTitle'.tr(),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.brandTint,
                backgroundImage: preview.logoUrl != null
                    ? NetworkImage(preview.logoUrl!)
                    : null,
                child: preview.logoUrl == null
                    ? Text(
                        preview.shortName.isNotEmpty
                            ? preview.shortName[0]
                            : '?',
                      )
                    : null,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.name,
                      style: textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.isNotEmpty)
                      Text(location, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text('joinUniversity.confirmDesc'.tr(), style: textTheme.bodySmall),
          const SizedBox(height: AppTheme.spaceMd),
          PrimaryActionButton(
            label: 'joinUniversity.sendRequest'.tr(),
            onPressed: onConfirm,
            isLoading: isSubmitting,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          TextButton(
            onPressed: isSubmitting ? null : onCancel,
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }
}
