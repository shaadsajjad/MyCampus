import 'package:flutter/foundation.dart';
import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';
import 'package:mycampus/core/config/app_config.dart';

/// Resolves the PocketBase URL for the development flavor.
///
/// Three defaults, in priority order:
///
/// 1. `--dart-define=POCKETBASE_URL=http://<ip>:8090` — explicit override,
///    required when running on a physical device that needs to reach a
///    PocketBase on a different machine (e.g. a phone on the same Wi-Fi as
///    your laptop — use the laptop's LAN IP, and start PocketBase with
///    `./pocketbase serve --http=0.0.0.0:8090` so it listens on all
///    interfaces).
/// 2. Android emulator → `http://10.0.2.2:8090`. The emulator's special
///    loopback alias for the host machine (so PB must be bound to
///    `127.0.0.1` or `0.0.0.0`, which is the default).
/// 3. Everything else (iOS simulator, web, macOS, Windows) → `http://127.0.0.1:8090`.
///
/// Start PocketBase with `./pocketbase serve` from inside the `pocketbase/`
/// directory — it auto-runs the committed migrations on first launch.
String get _developmentPocketbaseUrl {
  const override = String.fromEnvironment('POCKETBASE_URL');
  if (override.isNotEmpty) return override;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    // 10.0.2.2 is the Android emulator's alias for the host machine's
    // loopback. There's no way for the app to ask "what's the host IP"
    // without extra setup (e.g. an mdns service), and this default works
    // for the common "run the emulator next to a local PB" case.
    return 'http://10.0.2.2:8090';
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
