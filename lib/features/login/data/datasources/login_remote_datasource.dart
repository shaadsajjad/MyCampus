import 'package:mycampus/features/login/domain/exceptions/login_exception.dart' show LoginException;
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `login` feature that talks to the PocketBase SDK
/// directly — `LoginRepositoryImpl` works with plain values and
/// [LoginException], never `ClientException`.
abstract class LoginRemoteDataSource {
  Future<void> login({required String email, required String password});

  Future<void> requestVerification(String email);

  Future<void> requestPasswordReset(String email);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  new(this._pb);

  final PocketBase _pb;

  @override
  Future<void> login({required String email, required String password}) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  @override
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _pb.collection('users').requestPasswordReset(email);
  }
}
