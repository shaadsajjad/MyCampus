import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/splash_cubit.dart';
import '../widgets/initial_splash.dart';
import 'onboarding_page.dart';

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
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (context, state) {
        switch (state.phase) {
          case SplashPhase.initial:
            return const InitialSplash();
          case SplashPhase.onboarding:
            return const OnboardingPage();
        }
      },
    );
  }
}