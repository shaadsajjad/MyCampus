import 'package:flutter/foundation.dart';
import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';
import 'package:mycampus/core/config/app_config.dart';

/// `127.0.0.1` means "this device itself" — on Android that's the phone
/// or emulator, never the host Mac running PocketBase. The Mac's LAN IP
/// works for both a real device and the emulator, as long as both are on
/// the same Wi-Fi network and PocketBase is bound to `0.0.0.0`, not just
/// loopback (`./pocketbase serve --http=0.0.0.0:8090`).
///
/// Override without a code change via
/// `flutter run --dart-define=POCKETBASE_URL=http://<ip>:8090` — handy
/// since this IP changes if your Mac reconnects to Wi-Fi/gets a new DHCP
/// lease.
const _macLanIp = '192.168.0.102';

String get _developmentPocketbaseUrl {
  const override = String.fromEnvironment('POCKETBASE_URL');
  if (override.isNotEmpty) return override;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://$_macLanIp:8090';
  }
  return 'http://127.0.0.1:8090';
}

Future<void> main() async {
  AppConfig.init(
    flavor: AppFlavor.development,
    pocketbaseUrl: _developmentPocketbaseUrl,
  );
  await bootstrap(() => const App());
}
