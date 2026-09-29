import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class LoginState {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
  });

  final String email;
  final String password;
  final bool obscurePassword;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  /// Owned here (not in a [StatefulWidget]) so the login page can stay a
  /// plain [StatelessWidget] while still validating on submit.
  final formKey = GlobalKey<FormState>();

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void passwordChanged(String value) =>
      emit(state.copyWith(password: value));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  /// Placeholder until the PocketBase auth repository is wired in.
  void submit() {
    if (!formKey.currentState!.validate()) return;
    // TODO(pocketbase): authenticate via AuthRepository.login(...).
  }
}
