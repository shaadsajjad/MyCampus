import 'package:go_router/go_router.dart';
import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/features/auth/presentation/pages/login_page.dart';
import 'package:mycampus/features/auth/presentation/pages/student_register_page.dart';
import 'package:mycampus/features/auth/presentation/pages/super_admin_register_page.dart';
import 'package:mycampus/features/auth/presentation/pages/teacher_register_page.dart';
import 'package:mycampus/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mycampus/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mycampus/features/splash/presentation/pages/splash_page.dart';

abstract class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const registerSuperAdmin = '/auth/register/super-admin';
  static const registerStudent = '/auth/register/student';
  static const registerTeacher = '/auth/register/teacher';
  static const dashboard = '/dashboard';

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

  static UserRole _roleFromQuery(GoRouterState state) {
    final raw = state.uri.queryParameters['role'];
    return UserRole.values.firstWhere(
      (role) => role.name == raw,
      orElse: () => UserRole.student,
    );
  }
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
        path: AppRoute.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}
