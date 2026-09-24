part of 'sign_in_bloc.dart';

enum SignInStatus { editing, submitting, success, failure }

final class SignInState extends Equatable {
  const SignInState({
    this.email = '',
    this.password = '',
    this.touched = const {},
    this.submitAttempted = false,
    this.status = SignInStatus.editing,
    this.failure,
  });

  final String email;
  final String password;

  /// Fields the user has already left. Errors show only for these, or for
  /// every field once the user has tried to submit. This avoids showing
  /// "invalid email" after the first keystroke.
  final Set<SignInField> touched;
  final bool submitAttempted;
  final SignInStatus status;
  final Failure? failure;

  EmailError? get emailError => CredentialValidators.email(email);
  PasswordError? get passwordError => CredentialValidators.password(password);
  bool get isValid => emailError == null && passwordError == null;
  bool get isSubmitting => status == SignInStatus.submitting;

  EmailError? get visibleEmailError =>
      _visible(SignInField.email) ? emailError : null;

  PasswordError? get visiblePasswordError =>
      _visible(SignInField.password) ? passwordError : null;

  bool _visible(SignInField field) =>
      submitAttempted || touched.contains(field);

  SignInState copyWith({
    String? email,
    String? password,
    Set<SignInField>? touched,
    bool? submitAttempted,
    SignInStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      touched: touched ?? this.touched,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      status:
          status ??
          (clearFailure && this.status == SignInStatus.failure
              ? SignInStatus.editing
              : this.status),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    touched,
    submitAttempted,
    status,
    failure,
  ];
}
