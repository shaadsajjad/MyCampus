import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mycampus/core/router/app_router.dart';
import 'package:mycampus/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:mycampus/features/splash/presentation/widgets/initial_splash.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashStatus>(
      listener: (context, status) {
        switch (status) {
          case SplashStatus.readyAuthenticated:
            context.go(AppRoute.dashboard);
          case SplashStatus.readyUnauthenticated:
            context.go(AppRoute.onboarding);
          case SplashStatus.loading:
            break;
        }
      },
      child: const InitialSplash(),
    );
  }
}
