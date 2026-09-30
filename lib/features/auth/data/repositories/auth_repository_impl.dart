import 'dart:async';
import 'dart:typed_data';

import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycampus/features/auth/data/models/user_model.dart';
import 'package:mycampus/features/auth/domain/entities/account_status.dart';
import 'package:mycampus/features/auth/domain/entities/auth_user.dart';
import 'package:mycampus/features/auth/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/auth/domain/entities/university_type.dart';
import 'package:mycampus/features/auth/domain/exceptions/auth_exception.dart';
import 'package:mycampus/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final AuthRemoteDataSource _remote;

  @override
  AuthUser? get currentUser {
    final user = _remote.currentUser;
    return user == null ? null : _toAuthUser(user);
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    return _guard(() async {
      final user = await _remote.login(email: email, password: password);
      return _toAuthUser(user);
    });
  }

  @override
  Future<AuthUser> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String studentId,
    required String department,
    required String batch,
    Uint8List? photoBytes,
  }) {
    return _guard(() async {
      final user = await _remote.createUser({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': fullName,
        'phone': phone,
        'role': UserRole.student.name,
        'status': AccountStatus.pending.name,
      }, avatarBytes: photoBytes);

      await _remote.createStudentProfile({
        'user': user.id,
        'studentId': studentId,
        'department': department,
        'batch': batch,
      });

      return _toAuthUser(user);
    });
  }

  @override
  Future<AuthUser> registerTeacher({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String teacherId,
    required String department,
    required TeacherDesignation designation,
    Uint8List? photoBytes,
  }) {
    return _guard(() async {
      final user = await _remote.createUser({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': fullName,
        'phone': phone,
        'role': UserRole.faculty.name,
        'status': AccountStatus.pending.name,
      }, avatarBytes: photoBytes);

      await _remote.createTeacherProfile({
        'user': user.id,
        'teacherId': teacherId,
        'department': department,
        'designation': designation.name,
      });

      return _toAuthUser(user);
    });
  }

  @override
  Future<AuthUser> registerSuperAdmin({
    required String universityName,
    required String shortName,
    required UniversityType universityType,
    required String city,
    required String country,
    required String adminName,
    required String adminEmail,
    required String adminPassword,
    DateTime? establishedAt,
    Uint8List? logoBytes,
  }) {
    return _guard(() async {
      final user = await _remote.createUser({
        'email': adminEmail,
        'password': adminPassword,
        'passwordConfirm': adminPassword,
        'name': adminName,
        'role': UserRole.superAdmin.name,
        // Super admins own the university they create — no one else to
        // approve them.
        'status': AccountStatus.approved.name,
      });

      final university = await _remote.createUniversity({
        'name': universityName,
        'shortName': shortName,
        'type': universityType.name,
        'city': city,
        'country': country,
        if (establishedAt != null)
          'establishedAt': establishedAt.toIso8601String(),
        'admin': user.id,
      }, logoBytes: logoBytes);

      final updated = await _remote.updateUser(user.id, {
        'university': university.id,
      });

      return _toAuthUser(updated);
    });
  }

  @override
  Future<void> logout() => _remote.logout();

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a
  /// human-readable [AuthException], the only failure type above this
  /// layer needs to handle. A bare 15s timeout guards against the request
  /// hanging forever (e.g. the app pointed at a host it can't actually
  /// reach), which would otherwise leave the UI stuck showing a spinner
  /// with no error and no way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw AuthException(_messageFor(e));
    } on TimeoutException {
      throw const AuthException(
        'Could not reach the server. Check that PocketBase is running and '
        'reachable from this device, then try again.',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Something went wrong. Please try again. ($e)');
    }
  }

  /// PocketBase returns structured field-level validation errors (e.g.
  /// `{"data": {"email": {"message": "..."}}}`) — surface the first one
  /// when present, otherwise fall back to its top-level message. This is
  /// necessarily plain English: translating arbitrary backend error text
  /// is out of scope, so it isn't run through `en.json`.
  String _messageFor(ClientException e) {
    final data = e.response['data'];
    if (data is Map && data.isNotEmpty) {
      final field = data.keys.first;
      final firstError = data.values.first;
      if (firstError is Map && firstError['message'] is String) {
        return '$field: ${firstError['message']}';
      }
    }
    final message = e.response['message'];
    if (message is String && message.isNotEmpty) return message;
    // Temporary: surfaces the raw server response so an unexpected shape
    // is debuggable instead of hidden behind a generic message.
    return 'Request failed (${e.statusCode}): ${e.response}';
  }

  AuthUser _toAuthUser(UserModel user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      role: _parseRole(user.role),
      status: _parseStatus(user.status),
      name: user.name,
      universityId: user.universityId,
    );
  }

  UserRole _parseRole(String value) {
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return UserRole.student;
  }

  AccountStatus _parseStatus(String value) {
    for (final status in AccountStatus.values) {
      if (status.name == value) return status;
    }
    return AccountStatus.pending;
  }
}
