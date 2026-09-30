import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/register/domain/entities/teacher_designation.dart';
import 'package:mycampus/features/register/domain/exceptions/register_exception.dart';
import 'package:mycampus/features/register/domain/repositories/register_repository.dart';
import 'package:mycampus/features/register/presentation/submission_status.dart';

class TeacherRegisterState {
  const TeacherRegisterState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.photoBytes,
    this.teacherId = '',
    this.department,
    this.designation,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  /// Optional — left unset if not provided.
  final Uint8List? photoBytes;
  final String teacherId;
  final String? department;
  final TeacherDesignation? designation;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final SubmissionStatus status;
  final String? errorMessage;

  TeacherRegisterState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    Uint8List? photoBytes,
    bool clearPhoto = false,
    String? teacherId,
    String? department,
    TeacherDesignation? designation,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TeacherRegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
      teacherId: teacherId ?? this.teacherId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TeacherRegisterCubit extends Cubit<TeacherRegisterState> {
  TeacherRegisterCubit({RegisterRepository? registerRepository})
    : _registerRepository = registerRepository ?? DI.registerRepository,
      super(const TeacherRegisterState());

  final RegisterRepository _registerRepository;
  final formKey = GlobalKey<FormState>();

  void fullNameChanged(String v) => emit(state.copyWith(fullName: v));

  void emailChanged(String v) => emit(state.copyWith(email: v));

  void phoneChanged(String v) => emit(state.copyWith(phone: v));

  void passwordChanged(String v) => emit(state.copyWith(password: v));

  void confirmPasswordChanged(String v) =>
      emit(state.copyWith(confirmPassword: v));

  void photoChanged(Uint8List bytes) => emit(state.copyWith(photoBytes: bytes));

  void removePhoto() => emit(state.copyWith(clearPhoto: true));

  void teacherIdChanged(String v) => emit(state.copyWith(teacherId: v));

  void departmentChanged(String? v) => emit(state.copyWith(department: v));

  void designationChanged(TeacherDesignation? v) =>
      emit(state.copyWith(designation: v));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _registerRepository.registerTeacher(
        fullName: state.fullName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        teacherId: state.teacherId,
        department: state.department!,
        designation: state.designation!,
        photoBytes: state.photoBytes,
      );
      emit(state.copyWith(status: SubmissionStatus.success));
    } on RegisterException catch (e) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
