import 'package:mycampus/app/app.dart';
import 'package:mycampus/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
