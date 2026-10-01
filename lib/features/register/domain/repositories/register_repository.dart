import 'dart:typed_data';

import 'package:mycampus/features/register/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/register/domain/entities/university_type.dart';
import 'package:mycampus/features/register/domain/exceptions/register_exception.dart'
    show RegisterException;

/// The contract the three registration screens code against;
/// [RegisterException] is the only failure type they need to know about —
/// everything else (PocketBase, HTTP, ...) is a data-layer detail behind
/// this interface. Each method also requests a verification email as its
/// last step — the caller doesn't need to do that separately.
abstract class RegisterRepository {
  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String studentId,
    required String department,
    required String batch,
    Uint8List? photoBytes,
  });

  Future<void> registerTeacher({
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
  });
}
