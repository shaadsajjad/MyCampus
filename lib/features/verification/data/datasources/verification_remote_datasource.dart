import 'package:pocketbase/pocketbase.dart';

/// The only file in the `verification` feature that talks to the
/// PocketBase SDK directly — `VerificationRepositoryImpl` works with plain
/// values and [VerificationException], never `RecordModel`/
/// `ClientException`.
abstract class VerificationRemoteDataSource {
  Future<void> confirmVerification(String token);

  Future<void> requestVerification(String email);

  /// Authenticates and reports the account's `verified` flag.
  Future<bool> login({required String email, required String password});

  bool get hasActiveSession;

  Future<void> logout();
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  Future<void> confirmVerification(String token) async {
    await _pb.collection('users').confirmVerification(token);
  }

  @override
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  @override
  Future<bool> login({required String email, required String password}) async {
    final auth = await _pb
        .collection('users')
        .authWithPassword(email, password);
    return auth.record.getBoolValue('verified');
  }

  @override
  bool get hasActiveSession => _pb.authStore.record != null;

  @override
  Future<void> logout() async => _pb.authStore.clear();
}
