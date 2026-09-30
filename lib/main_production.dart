import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';
import 'package:mycampus/core/config/app_config.dart';

Future<void> main() async {
  AppConfig.init(
    flavor: AppFlavor.production,
    // TODO(pocketbase): replace with the deployed production PocketBase URL.
    pocketbaseUrl: 'https://api.mycampus.example.com',
  );
  await bootstrap(() => const App());
}
