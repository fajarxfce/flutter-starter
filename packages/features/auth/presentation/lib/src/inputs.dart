import 'package:formz/formz.dart';

enum InputError { empty, invalid }

class EmailInput extends FormzInput<String, InputError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();
  @override
  InputError? validator(String value) {
    if (value.isEmpty) return InputError.empty;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)
        ? null
        : InputError.invalid;
  }
}

class PasswordInput extends FormzInput<String, InputError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();
  @override
  InputError? validator(String value) => value.isEmpty
      ? InputError.empty
      : value.length < 8
      ? InputError.invalid
      : null;
}
