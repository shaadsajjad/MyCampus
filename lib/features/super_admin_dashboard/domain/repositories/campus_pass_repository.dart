import 'package:mycampus/features/super_admin_dashboard/domain/entities/campus_pass.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/campus_pass_exception.dart' show CampusPassException;

/// Exports the campus pass as an image. [CampusPassException] is the only
/// failure type callers need to handle.
abstract class CampusPassRepository {
  Future<void> saveToGallery(CampusPass pass);

  /// Opens the OS share sheet with the pass image attached and [message]
  /// as the accompanying text. Returns normally whether the user shared or
  /// dismissed the sheet.
  Future<void> share(
    CampusPass pass, {
    required String message,
    ShareAnchor? anchor,
  });
}
