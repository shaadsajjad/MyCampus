import 'dart:typed_data';
import 'dart:ui';

import 'package:gal/gal.dart';
import 'package:mycampus/features/super_admin_dashboard/data/datasources/campus_pass_export_datasource.dart';
import 'package:mycampus/features/super_admin_dashboard/data/datasources/campus_pass_image_renderer.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/entities/campus_pass.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/campus_pass_exception.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/repositories/campus_pass_repository.dart';

class CampusPassRepositoryImpl implements CampusPassRepository {
  new({
    this._renderer = const CampusPassImageRenderer(),
    this._exporter = const CampusPassExportDataSourceImpl(),
  });

  final CampusPassImageRenderer _renderer;
  final CampusPassExportDataSource _exporter;

  @override
  Future<void> saveToGallery(CampusPass pass) {
    return _guard(() async {
      final png = await _render(pass);
      await _exporter.saveImage(png, name: _baseName(pass));
    });
  }

  @override
  Future<void> share(
    CampusPass pass, {
    required String message,
    ShareAnchor? anchor,
  }) {
    return _guard(() async {
      final png = await _render(pass);
      await _exporter.shareImage(
        png,
        fileName: '${_baseName(pass)}.png',
        text: message,
        origin: anchor == null
            ? null
            : Rect.fromLTWH(
                anchor.left,
                anchor.top,
                anchor.width,
                anchor.height,
              ),
      );
    });
  }

  Future<Uint8List> _render(CampusPass pass) => _renderer.render(
    campusId: pass.campusId,
    universityName: pass.universityName,
  );

  String _baseName(CampusPass pass) => 'mycampus_pass_${pass.campusId}';

  /// Every failure becomes a [CampusPassException], so nothing escapes the
  /// Cubit silently — including a `MissingPluginException` from running a
  /// build made before `gal`/`share_plus` were added (hot restart isn't
  /// enough; the app has to be rebuilt).
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on GalException catch (e) {
      throw CampusPassException(
        e.type == GalExceptionType.accessDenied
            ? CampusPassFailure.permissionDenied
            : CampusPassFailure.unknown,
        e,
      );
    } on CampusPassException {
      rethrow;
    } on Object catch (e) {
      throw CampusPassException(CampusPassFailure.unknown, e);
    }
  }
}
