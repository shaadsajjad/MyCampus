import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/login/data/datasources/login_remote_datasource.dart';
import 'package:mycampus/features/login/domain/exceptions/login_exception.dart';
import 'package:mycampus/features/login/domain/repositories/login_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginRepositoryImpl implements LoginRepository {
  new({required LoginRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final LoginRemoteDataSource _remote;

  @override
  Future<void> login({required String email, required String password}) {
    return _guard(() => _remote.login(email: email, password: password));
  }

  @override
  Future<void> requestVerification(String email) {
    return _guard(() => _remote.requestVerification(email));
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _guard(() => _remote.requestPasswordReset(email));
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [LoginException], the only failure type above this layer needs to
  /// handle. A bare 15s timeout guards against the request hanging forever
  /// (e.g. the app pointed at a host it can't actually reach), which would
  /// otherwise leave the UI stuck showing a spinner with no error and no
  /// way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw LoginException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      // Translation key — `translate_error.dart` walks the em-dash of
      // PocketBase English text via `cubit.translateError(e.message)` on
      // the other side, and `.tr()`s anything under the `error.*` prefix.
      throw const LoginException('error.unreachableServer');
    } catch (e) {
      throw const LoginException('error.unknown');
    }
  }
}
