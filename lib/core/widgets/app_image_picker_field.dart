import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:mycampus/core/theme/app_theme.dart';

enum ImagePickerShape { circle, roundedSquare }

/// A tap-to-pick image field (profile photo, university logo, ...) bound
/// to a Cubit's state. Picking is a one-shot platform interaction, so —
/// same pattern as `AppMonthYearField` — this widget calls [ImagePicker]
/// directly and hands the resulting bytes to [onChanged]; the Cubit just
/// stores them.
class AppImagePickerField extends StatelessWidget {
  const AppImagePickerField({
    required this.label,
    required this.imageBytes,
    required this.onChanged,
    this.onRemove,
    this.shape = ImagePickerShape.circle,
    this.isRequired = false,
    this.size = 96,
    super.key,
  });

  final String label;
  final Uint8List? imageBytes;
  final ValueChanged<Uint8List> onChanged;
  final VoidCallback? onRemove;
  final ImagePickerShape shape;
  final bool isRequired;
  final double size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCircle = shape == ImagePickerShape.circle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: textTheme.labelMedium),
            if (isRequired) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: textTheme.labelMedium?.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Center(
          child: GestureDetector(
            onTap: () => _openPicker(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle
                        ? null
                        : BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.outline),
                    image: imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(imageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageBytes == null
                      ? Icon(
                          isCircle
                              ? Icons.person_outline
                              : Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: AppColors.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceCard,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColors.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('common.takePhoto'.tr()),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('common.chooseFromGallery'.tr()),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            if (imageBytes != null && onRemove != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'common.removePhoto'.tr(),
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  onRemove!();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    onChanged(bytes);
  }
}
