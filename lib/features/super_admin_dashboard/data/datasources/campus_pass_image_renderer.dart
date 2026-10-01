import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:mycampus/core/constants/app_assets.dart';
import 'package:mycampus/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Draws the exportable campus pass — QR on a white card with the
/// university name and campus id underneath — straight to PNG bytes.
///
/// Rendered off-screen rather than screenshotting the on-screen card, so
/// the export doesn't depend on that widget being mounted or laid out, and
/// always comes out at print resolution with an opaque white background
/// (the on-screen QR sits on a transparent background, which disappears in
/// a dark-mode photo viewer).
class CampusPassImageRenderer {
  const new();

  static const double _width = 1080;
  static const double _padding = 96;

  Future<Uint8List> render({
    required String campusId,
    String? universityName,
  }) async {
    const qrSize = _width - _padding * 2;
    const contentWidth = _width - _padding * 2;

    final logo = await _loadLogo();
    final qr = QrPainter(
      data: campusId,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.primary,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.primary,
      ),
      embeddedImage: logo,
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size.square(qrSize * 0.18),
      ),
    );

    final name = _layoutText(
      universityName ?? '',
      maxWidth: contentWidth,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
    final id = _layoutText(
      campusId,
      maxWidth: contentWidth,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 36,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
        color: AppColors.onSurfaceVariant,
      ),
    );

    final hasName = universityName != null && universityName.isNotEmpty;
    final height =
        _padding +
        qrSize +
        64 +
        (hasName ? name.height + 20 : 0) +
        id.height +
        _padding;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawRect(
        Rect.fromLTWH(0, 0, _width, height),
        Paint()..color = const Color(0xFFFFFFFF),
      )
      ..save()
      ..translate(_padding, _padding);
    qr.paint(canvas, const Size.square(qrSize));
    canvas.restore();

    var y = _padding + qrSize + 64;
    if (hasName) {
      name.paint(canvas, Offset((_width - name.width) / 2, y));
      y += name.height + 20;
    }
    id.paint(canvas, Offset((_width - id.width) / 2, y));

    final image = await recorder.endRecording().toImage(
      _width.toInt(),
      height.ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    logo?.dispose();
    name.dispose();
    id.dispose();
    if (bytes == null) {
      throw StateError('Could not encode the campus pass as PNG');
    }
    return bytes.buffer.asUint8List();
  }

  TextPainter _layoutText(
    String text, {
    required double maxWidth,
    required TextStyle style,
  }) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
  }

  /// The QR still scans without the logo, so a missing/undecodable asset
  /// just drops it rather than failing the whole export.
  Future<ui.Image?> _loadLogo() async {
    try {
      final data = await rootBundle.load(AppAssets.logo);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 256,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } on Exception {
      return null;
    }
  }
}
