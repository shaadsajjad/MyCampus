import 'dart:typed_data';

import 'package:mycampus/features/auth/domain/entities/auth_user.dart';
import 'package:mycampus/features/auth/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/auth/domain/entities/university_type.dart';

/// The contract the presentation layer codes against; `AuthException` is
/// the only failure type it needs to know about — everything else
/// (PocketBase, HTTP, ...) is a data-layer detail behind this interface.
abstract class AuthRepository {
  /// The currently authenticated user, if any — read from the persisted
  /// auth store, so this is valid across app restarts without a network
  /// call.
  AuthUser? get currentUser;

  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String studentId,
    required String department,
    required String batch,
    Uint8List? photoBytes,
  });

  Future<AuthUser> registerTeacher({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String teacherId,
    required String department,
    required TeacherDesignation designation,
    Uint8List? photoBytes,
  });

  /// Creates both the university and its owning super admin account.
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
  });

  Future<void> logout();
}
