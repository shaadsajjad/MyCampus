import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

/// The only file in the `register` feature that talks to the PocketBase
/// SDK directly — `RegisterRepositoryImpl` works with plain ids/values and
/// [RegisterException], never `RecordModel`/`ClientException`. Every method
/// here returns just the new record's id (or nothing) since that's all a
/// registration flow ever needs back.
abstract class RegisterRemoteDataSource {
  Future<String> createUser(
    Map<String, dynamic> body, {
    Uint8List? avatarBytes,
  });

  Future<void> updateUser(String id, Map<String, dynamic> body);

  Future<void> createStudentProfile(Map<String, dynamic> body);

  Future<void> createTeacherProfile(Map<String, dynamic> body);

  Future<String> createUniversity(
    Map<String, dynamic> body, {
    Uint8List? logoBytes,
  });

  /// Authenticates as the just-created account — needed only to bridge a
  /// PocketBase quirk during super admin registration (see
  /// `RegisterRepositoryImpl.registerSuperAdmin`), not a general "log in"
  /// entry point.
  Future<void> loginAsNewAccount(String email, String password);

  Future<void> requestVerification(String email);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  RegisterRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  Future<String> createUser(
    Map<String, dynamic> body, {
    Uint8List? avatarBytes,
  }) async {
    final record = await _pb
        .collection('users')
        .create(body: body, files: _filesFor('avatar', avatarBytes));
    return record.id;
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> body) async {
    await _pb.collection('users').update(id, body: body);
  }

  @override
  Future<void> createStudentProfile(Map<String, dynamic> body) async {
    await _pb.collection('students').create(body: body);
  }

  @override
  Future<void> createTeacherProfile(Map<String, dynamic> body) async {
    await _pb.collection('teachers').create(body: body);
  }

  @override
  Future<String> createUniversity(
    Map<String, dynamic> body, {
    Uint8List? logoBytes,
  }) async {
    final record = await _pb
        .collection('universities')
        .create(body: body, files: _filesFor('logo', logoBytes));
    return record.id;
  }

  @override
  Future<void> loginAsNewAccount(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  @override
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  List<http.MultipartFile> _filesFor(String field, Uint8List? bytes) {
    if (bytes == null) return const [];
    return [http.MultipartFile.fromBytes(field, bytes, filename: '$field.jpg')];
  }
}
