import 'package:pocketbase/pocketbase.dart';

/// The only file in the `login` feature that talks to the PocketBase SDK
/// directly — `LoginRepositoryImpl` works with plain values and
/// [LoginException], never `ClientException`.
abstract class LoginRemoteDataSource {
  Future<void> login({required String email, required String password});

  Future<void> requestVerification(String email);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  LoginRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  Future<void> login({required String email, required String password}) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  @override
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }
}
