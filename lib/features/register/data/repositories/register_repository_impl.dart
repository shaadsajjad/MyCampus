import 'dart:async';
import 'dart:typed_data';

import 'package:mycampus/core/domain/entities/user_role.dart';
import 'package:mycampus/core/utils/pocketbase_error.dart';
import 'package:mycampus/features/register/data/datasources/register_remote_datasource.dart';
import 'package:mycampus/features/register/domain/entities/account_status.dart';
import 'package:mycampus/features/register/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/register/domain/entities/university_type.dart';
import 'package:mycampus/features/register/domain/exceptions/register_exception.dart';
import 'package:mycampus/features/register/domain/repositories/register_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  new({required RegisterRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RegisterRemoteDataSource _remote;

  @override
  Future<void> registerStudent({
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
      final userId = await _remote.createUser({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': fullName,
        'phone': phone,
        'role': UserRole.student.name,
        'status': AccountStatus.pending.name,
      }, avatarBytes: photoBytes);

      await _remote.createStudentProfile({
        'user': userId,
        'studentId': studentId,
        'department': department,
        'batch': batch,
      });

      await _remote.requestVerification(email);
    });
  }

  @override
  Future<void> registerTeacher({
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
      final userId = await _remote.createUser({
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': fullName,
        'phone': phone,
        'role': UserRole.faculty.name,
        'status': AccountStatus.pending.name,
      }, avatarBytes: photoBytes);

      await _remote.createTeacherProfile({
        'user': userId,
        'teacherId': teacherId,
        'department': department,
        'designation': designation.name,
      });

      await _remote.requestVerification(email);
    });
  }

  @override
  Future<void> registerSuperAdmin({
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
      final userId = await _remote.createUser({
        'email': adminEmail,
        'password': adminPassword,
        'passwordConfirm': adminPassword,
        'name': adminName,
        'role': UserRole.superAdmin.name,
        // Super admins own the university they create — no one else to
        // approve them.
        'status': AccountStatus.approved.name,
      });

      // Creating a record doesn't establish a session, but the `users`
      // collection only allows a record to update itself
      // (`updateRule: id = @request.auth.id`) — without logging in first,
      // the `updateUser` call below linking the university back would be
      // rejected even though the account was just created successfully.
      await _remote.loginAsNewAccount(adminEmail, adminPassword);

      final universityId = await _remote.createUniversity({
        'name': universityName,
        'shortName': shortName,
        'type': universityType.name,
        'city': city,
        'country': country,
        if (establishedAt != null)
          'establishedAt': establishedAt.toIso8601String(),
        'admin': userId,
      }, logoBytes: logoBytes);

      await _remote.updateUser(userId, {'university': universityId});

      await _remote.requestVerification(adminEmail);
    });
  }

  /// Runs [action], translating PocketBase's [ClientException] — and any
  /// other failure (unreachable host, timeout, ...) — into a human-readable
  /// [RegisterException], the only failure type above this layer needs to
  /// handle. A bare 15s timeout guards against the request hanging forever
  /// (e.g. the app pointed at a host it can't actually reach), which would
  /// otherwise leave the UI stuck showing a spinner with no error and no
  /// way out.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 15));
    } on ClientException catch (e) {
      throw RegisterException(pocketBaseErrorMessage(e));
    } on TimeoutException {
      throw const RegisterException('error.unreachableServer');
    } catch (e) {
      throw const RegisterException('error.unknown');
    }
  }
}
