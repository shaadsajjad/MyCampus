import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycampus/app/app.dart';
import 'package:mycampus/features/splash/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('App', () {
    testWidgets('renders SplashPage', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      expect(find.byType(SplashPage), findsOneWidget);

      // Let the splash timer fire so no pending timers leak past the test.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
