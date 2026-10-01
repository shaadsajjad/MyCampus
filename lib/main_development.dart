import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';
import 'package:mycampus/core/config/app_config.dart';

/// The host machine's LAN IP, used as the default PocketBase address for
/// every target except the Android emulator (which has its own loopback
/// alias below). Reachable from a physical device on the same Wi-Fi as well
/// as from the iOS simulator/desktop, so the same `flutter run` command
/// works across targets with no extra flags.
///
/// This changes if the machine switches networks or gets a new DHCP lease —
/// update it here, or override per-run without editing code (see below).
const _lanPocketbaseIp = '192.168.0.102';

/// Resolves the PocketBase URL for the development flavor.
///
/// Three defaults, in priority order:
///
/// 1. `--dart-define=POCKETBASE_URL=http://<ip>:8090` — explicit override,
///    for when [_lanPocketbaseIp] is stale (new network/DHCP lease) or you
///    want to point at a different PocketBase entirely.
/// 2. Android **emulator** specifically → `http://10.0.2.2:8090`. The
///    emulator's special loopback alias for the host machine (so PB must be
///    bound to `127.0.0.1` or `0.0.0.0`, which is the default). Checked via
///    [AndroidDeviceInfo.isPhysicalDevice] rather than just "is Android",
///    because `10.0.2.2` means nothing on a real phone — it isn't on the
///    phone's network at all, so a request to it just hangs until the
///    15s timeout in `login_repository_impl.dart` gives up.
/// 3. Everything else (physical device, iOS simulator, web, macOS, Windows)
///    → `http://$_lanPocketbaseIp:8090`.
///
/// Start PocketBase with `./pocketbase serve --http=0.0.0.0:8090` from
/// inside the `pocketbase/` directory, so it's reachable from other devices
/// on the network — it auto-runs the committed migrations on first launch.
Future<String> _developmentPocketbaseUrl() async {
  const override = String.fromEnvironment('POCKETBASE_URL');
  if (override.isNotEmpty) return override;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (!androidInfo.isPhysicalDevice) return 'http://10.0.2.2:8090';
  }
  return 'http://$_lanPocketbaseIp:8090';
}

Future<void> main() async {
  // Needed before any platform-channel call (DeviceInfoPlugin below) can
  // run; `bootstrap()` also calls this, but not until after the PocketBase
  // URL must already be resolved, and a second call is a no-op.
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(
    flavor: AppFlavor.development,
    pocketbaseUrl: await _developmentPocketbaseUrl(),
  );
  await bootstrap(() => const App());
}
