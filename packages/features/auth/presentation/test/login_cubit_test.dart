import 'dart:async';

import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core_common/core_common.dart';
import 'package:core_testing/core_testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  setUp(() => repository = MockAuthRepository());
  LoginCubit create() => LoginCubit(Login(repository));
  test('Formz validates email and minimum password length', () {
    expect(const EmailInput.dirty('invalid').isValid, isFalse);
    expect(const EmailInput.dirty('demo@example.com').isValid, isTrue);
    expect(const PasswordInput.dirty('short').isValid, isFalse);
    expect(const PasswordInput.dirty('Demo123!').isValid, isTrue);
  });
  blocTest<LoginCubit, LoginState>(
    'invalid form never calls repository',
    build: create,
    act: (cubit) => cubit.submit(),
    expect: () => [
      isA<LoginState>().having(
        (s) => s.email.displayError,
        'email error',
        isNotNull,
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ),
  );
  test('double submit sends one request and emits success', () async {
    final pending = Completer<Result<User>>();
    when(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).thenAnswer((_) => pending.future);
    final cubit = create()
      ..emailChanged('demo@example.com')
      ..passwordChanged('Demo123!');
    final first = cubit.submit();
    await cubit.submit();
    expect(cubit.state.status, FormzSubmissionStatus.inProgress);
    pending.complete(
      const Success(
        User(id: '1', email: 'demo@example.com', displayName: 'Demo'),
      ),
    );
    await first;
    expect(cubit.state.status, FormzSubmissionStatus.success);
    verify(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).called(1);
    await cubit.close();
  });
  test('repository failure is exposed as a user-facing message', () async {
    when(
      () => repository.login(email: 'demo@example.com', password: 'Demo123!'),
    ).thenAnswer(
      (_) async => const FailureResult(Failure(FailureKind.network, 'Offline')),
    );
    final cubit = create()
      ..emailChanged('demo@example.com')
      ..passwordChanged('Demo123!');
    await cubit.submit();
    expect(cubit.state.status, FormzSubmissionStatus.failure);
    expect(cubit.state.error, 'Offline');
    await cubit.close();
  });
}
