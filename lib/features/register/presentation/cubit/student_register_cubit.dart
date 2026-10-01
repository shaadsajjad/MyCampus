// ignore_for_file: avoid_flutter_imports, prefer_void_public_cubit_methods

import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/register/domain/exceptions/register_exception.dart';
import 'package:mycampus/features/register/domain/repositories/register_repository.dart';
import 'package:mycampus/features/register/presentation/submission_status.dart';

class StudentRegisterState {
  const new({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.photoBytes,
    this.studentId = '',
    this.department,
    this.batch = '',
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
  final String studentId;
  final String? department;
  final String batch;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final SubmissionStatus status;
  final String? errorMessage;

  StudentRegisterState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    Uint8List? photoBytes,
    bool clearPhoto = false,
    String? studentId,
    String? department,
    String? batch,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentRegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      batch: batch ?? this.batch,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StudentRegisterCubit extends Cubit<StudentRegisterState> {
  new({RegisterRepository? registerRepository})
    : _registerRepository = registerRepository ?? DI.registerRepository,
      super(const StudentRegisterState());

  final RegisterRepository _registerRepository;
  final _formKey = GlobalKey<FormState>();

  /// Public read-only accessor so pages can do `Form(key: cubit.formKey, ...)`
  /// without exposing the field itself — keeping the field private satisfies
  /// `bloc_lint.avoid_public_fields`. (See `clean_architecture.md`: form
  /// keys deliberately live on the cubit.)
  GlobalKey<FormState> get formKey => _formKey;

  void fullNameChanged(String v) => emit(state.copyWith(fullName: v));

  void emailChanged(String v) => emit(state.copyWith(email: v));

  void phoneChanged(String v) => emit(state.copyWith(phone: v));

  void passwordChanged(String v) => emit(state.copyWith(password: v));

  void confirmPasswordChanged(String v) =>
      emit(state.copyWith(confirmPassword: v));

  void photoChanged(Uint8List bytes) => emit(state.copyWith(photoBytes: bytes));

  void removePhoto() => emit(state.copyWith(clearPhoto: true));

  void studentIdChanged(String v) => emit(state.copyWith(studentId: v));

  void departmentChanged(String? v) => emit(state.copyWith(department: v));

  void batchChanged(String v) => emit(state.copyWith(batch: v));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _registerRepository.registerStudent(
        fullName: state.fullName,
        email: state.email,
        phone: state.phone,
        password: state.password,
        studentId: state.studentId,
        department: state.department!,
        batch: state.batch,
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