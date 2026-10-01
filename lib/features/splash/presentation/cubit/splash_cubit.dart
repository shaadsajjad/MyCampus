import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mycampus/core/di/di.dart';

enum SplashStatus { loading, readyAuthenticated, readyUnauthenticated }

class SplashCubit extends Cubit<SplashStatus> {
  new({Duration duration = const Duration(seconds: 3)})
    : super(SplashStatus.loading) {
    unawaited(_init(duration));
  }

  Future<void> _init(Duration duration) async {
    await Future<void>.delayed(duration);
    if (!isClosed) {
      emit(
        DI.pocketBase.authStore.isValid
            ? SplashStatus.readyAuthenticated
            : SplashStatus.readyUnauthenticated,
      );
    }
  }
}
