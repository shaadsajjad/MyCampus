import 'dart:async';

import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/verification/data/datasources/verification_remote_datasource.dart';
import 'package:mycampus/features/verification/domain/exceptions/verification_exception.dart';
import 'package:mycampus/features/verification/domain/repositories/verification_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl({
    required VerificationRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final VerificationRemoteDataSource _remote;

  @override
  Future<void> confirmVerification(String token) {
    return _guard(() => _remote.confirmVerification(token));
  }

  @override
  Future<void> requestVerification(String email) {
    return _guard(() => _remote.requestVerification(email));
  }

  @override
  Future<bool> loginIfVerified({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final verified = await _remote.login(email: email, password: password);
      if (!verified) await _remote.logout();
      return verified;
    });
  }

  @override
  bool get hasActiveSession => _remote.hasActiveSession;

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [VerificationException], the only failure type above this layer needs
  /// to handle. A bare 15s timeout guards against the request hanging
  /// forever (e.g. the app pointed at a host it can't actually reach),
  /// which would otherwise leave the UI stuck showing a spinner with no
  /// error and no way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw VerificationException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const VerificationException(
        'Could not reach the server. Check that PocketBase is running and '
        'reachable from this device, then try again.',
      );
    } catch (e) {
      throw VerificationException(
        'Something went wrong. Please try again. ($e)',
      );
    }
  }
}
