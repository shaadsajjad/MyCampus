import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class StudentRegisterState {
  const StudentRegisterState({
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
    );
  }
}

class StudentRegisterCubit extends Cubit<StudentRegisterState> {
  StudentRegisterCubit() : super(const StudentRegisterState());

  final formKey = GlobalKey<FormState>();

  void fullNameChanged(String v) => emit(state.copyWith(fullName: v));

  void emailChanged(String v) => emit(state.copyWith(email: v));

  void phoneChanged(String v) => emit(state.copyWith(phone: v));

  void passwordChanged(String v) => emit(state.copyWith(password: v));

  void confirmPasswordChanged(String v) =>
      emit(state.copyWith(confirmPassword: v));

  void photoChanged(Uint8List bytes) =>
      emit(state.copyWith(photoBytes: bytes));

  void removePhoto() => emit(state.copyWith(clearPhoto: true));

  void studentIdChanged(String v) => emit(state.copyWith(studentId: v));

  void departmentChanged(String? v) => emit(state.copyWith(department: v));

  void batchChanged(String v) => emit(state.copyWith(batch: v));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  /// Placeholder until the PocketBase repository is wired in.
  void submit() {
    if (!formKey.currentState!.validate()) return;
    // TODO(pocketbase): create the student account, pending admin approval.
  }
}
