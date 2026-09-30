import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';
import 'package:mycampus/core/config/app_config.dart';

Future<void> main() async {
  AppConfig.init(
    flavor: AppFlavor.staging,
    // TODO(pocketbase): replace with the deployed staging PocketBase URL.
    pocketbaseUrl: 'https://staging.mycampus.example.com',
  );
  await bootstrap(() => const App());
}
