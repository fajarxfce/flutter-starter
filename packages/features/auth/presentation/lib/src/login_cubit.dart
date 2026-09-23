import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/src/inputs.dart';
import 'package:core_common/core_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_cubit.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(EmailInput.pure()) EmailInput email,
    @Default(PasswordInput.pure()) PasswordInput password,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    String? error,
  }) = _LoginState;
}

final class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginState());
  final Login _login;
  void emailChanged(String value) {
    if (state.status.isInProgress) return;
    emit(
      state.copyWith(
        email: EmailInput.dirty(value.trim()),
        error: null,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void passwordChanged(String value) {
    if (state.status.isInProgress) return;
    emit(
      state.copyWith(
        password: PasswordInput.dirty(value),
        error: null,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> submit() async {
    if (state.status.isInProgress || state.status.isSuccess) return;
    final email = EmailInput.dirty(state.email.value);
    final password = PasswordInput.dirty(state.password.value);
    emit(state.copyWith(email: email, password: password, error: null));
    if (!Formz.validate([email, password])) return;
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    final result = await _login(email: email.value, password: password.value);
    if (isClosed) return;
    switch (result) {
      case Success<User>():
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      case FailureResult<User>(:final failure):
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            error: failure.message,
          ),
        );
    }
  }
}
