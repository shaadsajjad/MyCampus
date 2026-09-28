import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
    ],
  );
}