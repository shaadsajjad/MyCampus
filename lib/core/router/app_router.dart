import 'package:go_router/go_router.dart';
import 'package:mycampus/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mycampus/features/splash/presentation/pages/splash_page.dart';

abstract class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoute.splash,
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );
}
