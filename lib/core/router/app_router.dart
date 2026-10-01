import 'package:flutter/material.dart' show SnackBar;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/services/deep_link_service.dart'
    show DeepLinkService;
import 'package:mycampus/features/courses/presentation/pages/courses_page.dart';
import 'package:mycampus/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mycampus/features/join_university/presentation/pages/scan_join_page.dart';
import 'package:mycampus/features/login/presentation/pages/login_page.dart';
import 'package:mycampus/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mycampus/features/register/presentation/pages/student_register_page.dart';
import 'package:mycampus/features/register/presentation/pages/super_admin_register_page.dart';
import 'package:mycampus/features/register/presentation/pages/teacher_register_page.dart';
import 'package:mycampus/features/routine/presentation/pages/routine_page.dart';
import 'package:mycampus/features/splash/presentation/pages/splash_page.dart';
import 'package:mycampus/features/verification/presentation/pages/verification_page.dart';

abstract class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const registerSuperAdmin = '/auth/register/super-admin';
  static const registerStudent = '/auth/register/student';
  static const registerTeacher = '/auth/register/teacher';
  static const verification = '/auth/verify';
  static const dashboard = '/dashboard';

  /// Full-screen "scan campus QR / enter code" flow — role-agnostic
  /// (student and teacher both just update their own `users` record), so
  /// it isn't nested under either role's dashboard path.
  static const joinUniversity = '/join';

  /// The super admin's course catalogue — reached by pushing from the
  /// Home tab's "Academic Registry" card rather than sitting in the bottom
  /// nav, so the tab bar stays at the 5 items Material recommends. Pushed
  /// (not `go`) so the back button returns to the dashboard.
  static const courses = '/dashboard/courses';

  /// The super admin's weekly-timetable builder — same "pushed, not in the
  /// bottom nav" reasoning as [courses], reached from the same "Academic
  /// Registry" card.
  static const routine = '/dashboard/routine';

  /// The login screen for [role] — role travels as a query param since one
  /// screen serves all three roles.
  static String loginPathFor(UserRole role) => '$login?role=${role.name}';

  /// The role-specific registration screen for [role] — each role has its
  /// own dedicated path since their forms differ entirely.
  static String registerPathFor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return registerSuperAdmin;
      case UserRole.faculty:
        return registerTeacher;
      case UserRole.student:
        return registerStudent;
    }
  }

  /// Verification page route with email as query param.
  static String verificationPath(String email) =>
      '$verification?email=${Uri.encodeComponent(email)}';

  static UserRole _roleFromQuery(GoRouterState state) {
    final raw = state.uri.queryParameters['role'];
    return UserRole.values.firstWhere(
      (role) => role.name == raw,
      orElse: () => UserRole.student,
    );
  }

  static String _emailFromQuery(GoRouterState state) {
    return state.uri.queryParameters['email'] ?? '';
  }

  /// The password travels via `extra`, not a query param — go_router's
  /// `extra` stays in memory and is never encoded into the path, unlike
  /// [verificationPath]'s email.
  static String? _passwordFromExtra(GoRouterState state) {
    final extra = state.extra;
    return extra is String ? extra : null;
  }
}

class AppRouter {
  new _();

  /// Lets code without a [BuildContext] (e.g. [DeepLinkService], reacting
  /// to a verification link while the app is backgrounded) navigate or
  /// show a [SnackBar] via [navigatorKey.currentContext].
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
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
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) =>
            LoginPage(role: AppRoute._roleFromQuery(state)),
      ),
      GoRoute(
        path: AppRoute.registerSuperAdmin,
        builder: (context, state) => const SuperAdminRegisterPage(),
      ),
      GoRoute(
        path: AppRoute.registerStudent,
        builder: (context, state) => const StudentRegisterPage(),
      ),
      GoRoute(
        path: AppRoute.registerTeacher,
        builder: (context, state) => const TeacherRegisterPage(),
      ),
      GoRoute(
        path: AppRoute.verification,
        builder: (context, state) => VerificationPage(
          email: AppRoute._emailFromQuery(state),
          password: AppRoute._passwordFromExtra(state),
        ),
      ),
      GoRoute(
        path: AppRoute.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoute.joinUniversity,
        builder: (context, state) => const ScanJoinPage(),
      ),
      GoRoute(
        path: AppRoute.courses,
        builder: (context, state) => const CoursesPage(),
      ),
      GoRoute(
        path: AppRoute.routine,
        builder: (context, state) => const RoutinePage(),
      ),
    ],
  );
}
