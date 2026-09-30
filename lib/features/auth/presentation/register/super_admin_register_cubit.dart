import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mycampus/core/di/di.dart';
import 'package:mycampus/features/auth/domain/entities/university_type.dart';
import 'package:mycampus/features/auth/domain/exceptions/auth_exception.dart';
import 'package:mycampus/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycampus/features/auth/presentation/cubit/submission_status.dart';

class SuperAdminRegisterState {
  const SuperAdminRegisterState({
    this.universityName = '',
    this.shortName = '',
    this.universityType,
    this.city = '',
    this.country = '',
    this.establishedAt,
    this.logoBytes,
    this.adminName = '',
    this.adminEmail = '',
    this.adminPassword = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.status = SubmissionStatus.idle,
    this.errorMessage,
  });

  final String universityName;
  final String shortName;
  final UniversityType? universityType;
  final String city;
  final String country;

  /// Optional — left unset if not provided.
  final DateTime? establishedAt;

  /// Optional — left unset if not provided.
  final Uint8List? logoBytes;
  final String adminName;
  final String adminEmail;
  final String adminPassword;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final SubmissionStatus status;
  final String? errorMessage;

  SuperAdminRegisterState copyWith({
    String? universityName,
    String? shortName,
    UniversityType? universityType,
    String? city,
    String? country,
    DateTime? establishedAt,
    Uint8List? logoBytes,
    bool clearLogo = false,
    String? adminName,
    String? adminEmail,
    String? adminPassword,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    SubmissionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SuperAdminRegisterState(
      universityName: universityName ?? this.universityName,
      shortName: shortName ?? this.shortName,
      universityType: universityType ?? this.universityType,
      city: city ?? this.city,
      country: country ?? this.country,
      establishedAt: establishedAt ?? this.establishedAt,
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPassword: adminPassword ?? this.adminPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SuperAdminRegisterCubit extends Cubit<SuperAdminRegisterState> {
  SuperAdminRegisterCubit({AuthRepository? authRepository})
    : _authRepository = authRepository ?? DI.authRepository,
      super(const SuperAdminRegisterState());

  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();

  void universityNameChanged(String v) =>
      emit(state.copyWith(universityName: v));

  void shortNameChanged(String v) => emit(state.copyWith(shortName: v));

  void universityTypeChanged(UniversityType? v) =>
      emit(state.copyWith(universityType: v));

  void cityChanged(String v) => emit(state.copyWith(city: v));

  void countryChanged(String v) => emit(state.copyWith(country: v));

  void establishedAtChanged(DateTime v) =>
      emit(state.copyWith(establishedAt: v));

  void logoChanged(Uint8List bytes) => emit(state.copyWith(logoBytes: bytes));

  void removeLogo() => emit(state.copyWith(clearLogo: true));

  void adminNameChanged(String v) => emit(state.copyWith(adminName: v));

  void adminEmailChanged(String v) => emit(state.copyWith(adminEmail: v));

  void adminPasswordChanged(String v) => emit(state.copyWith(adminPassword: v));

  void confirmPasswordChanged(String v) =>
      emit(state.copyWith(confirmPassword: v));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(status: SubmissionStatus.submitting, clearError: true));
    try {
      await _authRepository.registerSuperAdmin(
        universityName: state.universityName,
        shortName: state.shortName,
        universityType: state.universityType!,
        city: state.city,
        country: state.country,
        establishedAt: state.establishedAt,
        logoBytes: state.logoBytes,
        adminName: state.adminName,
        adminEmail: state.adminEmail,
        adminPassword: state.adminPassword,
      );
      emit(state.copyWith(status: SubmissionStatus.success));
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
