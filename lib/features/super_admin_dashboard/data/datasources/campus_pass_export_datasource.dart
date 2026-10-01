import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:mycampus/features/super_admin_dashboard/domain/exceptions/campus_pass_exception.dart';
import 'package:share_plus/share_plus.dart';

/// The only file in the feature that talks to the device's photo library
/// and share sheet (`gal` / `share_plus`). Throws those packages' raw
/// errors — `CampusPassRepositoryImpl` maps them to [CampusPassException] —
/// except for an unsupported platform, which it knows up front.
abstract class CampusPassExportDataSource {
  Future<void> saveImage(Uint8List png, {required String name});

  Future<void> shareImage(
    Uint8List png, {
    required String fileName,
    required String text,
    Rect? origin,
  });
}

class CampusPassExportDataSourceImpl implements CampusPassExportDataSource {
  const new();

  @override
  Future<void> saveImage(Uint8List png, {required String name}) async {
    // `gal` has no web implementation — fail with a clear type instead of
    // a MissingPluginException.
    if (kIsWeb) {
      throw const CampusPassException(CampusPassFailure.unsupported);
    }
    await Gal.putImageBytes(png, name: name);
  }

  @override
  Future<void> shareImage(
    Uint8List png, {
    required String fileName,
    required String text,
    Rect? origin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [XFile.fromData(png, mimeType: 'image/png')],
        // `XFile.fromData`'s own `name` is ignored off the web; this is
        // what actually names the temp file the share sheet sees.
        fileNameOverrides: [fileName],
        sharePositionOrigin: origin,
      ),
    );
  }
}
