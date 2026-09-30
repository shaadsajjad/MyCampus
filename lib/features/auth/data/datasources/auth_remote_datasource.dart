import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mycampus/features/auth/data/models/student_profile_model.dart';
import 'package:mycampus/features/auth/data/models/teacher_profile_model.dart';
import 'package:mycampus/features/auth/data/models/university_model.dart';
import 'package:mycampus/features/auth/data/models/user_model.dart';
import 'package:pocketbase/pocketbase.dart';

/// The only file in the app that talks to the PocketBase SDK directly for
/// auth — everything above this (repository, cubits) works with the
/// `data/models` DTOs and `AuthException`, never `RecordModel` or
/// `ClientException` directly.
abstract class AuthRemoteDataSource {
  UserModel? get currentUser;

  Future<UserModel> login({required String email, required String password});

  Future<UserModel> createUser(
    Map<String, dynamic> body, {
    Uint8List? avatarBytes,
  });

  Future<UserModel> updateUser(String id, Map<String, dynamic> body);

  Future<StudentProfileModel> createStudentProfile(Map<String, dynamic> body);

  Future<TeacherProfileModel> createTeacherProfile(Map<String, dynamic> body);

  Future<UniversityModel> createUniversity(
    Map<String, dynamic> body, {
    Uint8List? logoBytes,
  });

  /// Sends a verification email to the given address.
  Future<void> requestVerification(String email);

  /// Confirms email verification with the token from the deep link.
  Future<void> confirmVerification(String token);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._pb);

  final PocketBase _pb;

  @override
  UserModel? get currentUser {
    final record = _pb.authStore.record;
    return record == null ? null : UserModel.fromRecord(record);
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final auth = await _pb
        .collection('users')
        .authWithPassword(email, password);
    return UserModel.fromRecord(auth.record);
  }

  @override
  Future<UserModel> createUser(
    Map<String, dynamic> body, {
    Uint8List? avatarBytes,
  }) async {
    final record = await _pb
        .collection('users')
        .create(body: body, files: _filesFor('avatar', avatarBytes));
    return UserModel.fromRecord(record);
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> body) async {
    final record = await _pb.collection('users').update(id, body: body);
    return UserModel.fromRecord(record);
  }

  @override
  Future<StudentProfileModel> createStudentProfile(
    Map<String, dynamic> body,
  ) async {
    final record = await _pb.collection('students').create(body: body);
    return StudentProfileModel.fromRecord(record);
  }

  @override
  Future<TeacherProfileModel> createTeacherProfile(
    Map<String, dynamic> body,
  ) async {
    final record = await _pb.collection('teachers').create(body: body);
    return TeacherProfileModel.fromRecord(record);
  }

  @override
  Future<UniversityModel> createUniversity(
    Map<String, dynamic> body, {
    Uint8List? logoBytes,
  }) async {
    final record = await _pb
        .collection('universities')
        .create(body: body, files: _filesFor('logo', logoBytes));
    final logoUrl = logoBytes == null
        ? null
        : _pb.files.getUrl(record, record.getStringValue('logo')).toString();
    return UniversityModel.fromRecord(record, logoUrl: logoUrl);
  }

  @override
  Future<void> requestVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  @override
  Future<void> confirmVerification(String token) async {
    await _pb.collection('users').confirmVerification(token);
  }

  @override
  Future<void> logout() async => _pb.authStore.clear();

  List<http.MultipartFile> _filesFor(String field, Uint8List? bytes) {
    if (bytes == null) return const [];
    return [http.MultipartFile.fromBytes(field, bytes, filename: '$field.jpg')];
  }
}
