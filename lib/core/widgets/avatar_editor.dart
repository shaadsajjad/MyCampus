import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycampus/core/widgets/app_image_picker_field.dart';

/// Opens the take-photo / gallery / remove sheet and resolves to picked
/// image bytes, or calls [onRemove] directly if "remove" was tapped.
///
/// Shared by every profile screen's avatar-edit affordance (tap the
/// `ProfileHeaderCard` avatar) so the pick → `ImagePicker` → `readAsBytes`
/// sequence exists in exactly one place, instead of once per feature.
Future<void> pickAndApplyAvatar(
  BuildContext context, {
  required bool hasAvatar,
  required ValueChanged<Uint8List> onPicked,
  required VoidCallback onRemove,
}) async {
  final source = await showImageSourcePicker(
    context,
    canRemove: hasAvatar,
    onRemove: onRemove,
  );
  if (source == null) return;

  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1024,
    imageQuality: 85,
  );
  if (picked == null) return;

  final bytes = await picked.readAsBytes();
  onPicked(bytes);
}
