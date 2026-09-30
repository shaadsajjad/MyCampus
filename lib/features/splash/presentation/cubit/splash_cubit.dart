import 'dart:async';

import 'package:bloc/bloc.dart';

enum SplashStatus { loading, ready }

class SplashCubit extends Cubit<SplashStatus> {
  SplashCubit({Duration duration = const Duration(seconds: 3)})
    : super(SplashStatus.loading) {
    unawaited(_init(duration));
  }

  Future<void> _init(Duration duration) async {
    await Future<void>.delayed(duration);
    if (!isClosed) {
      emit(SplashStatus.ready);
    }
  }
}
