part of 'sign_up_bloc.dart';

/// The screens of the sign-up flow, in order.
enum SignUpStep { credentials, phone, verify, profile }

enum SignUpField {
  email(SignUpStep.credentials),
  password(SignUpStep.credentials),
  phone(SignUpStep.phone),
  username(SignUpStep.profile),
  firstName(SignUpStep.profile),
  lastName(SignUpStep.profile),
  birthDate(SignUpStep.profile);

  const SignUpField(this.step);
  final SignUpStep step;
}

enum SignUpStatus { editing, submitting, success, failure }

final class SignUpState extends Equatable {
  const SignUpState({
    required this.today,
    this.email = '',
    this.password = '',
    this.phone = '',
    this.code = '',
    this.codeSentAt,
    this.resending = false,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.birthDate = '',
    this.photoPath,
    this.touched = const {},
    this.attempted = const {},
    this.step = SignUpStep.credentials,
    this.status = SignUpStatus.editing,
    this.failure,
  });

  /// Used for the age check. Taken from the bloc's clock so tests can pin
  /// it.
  final DateTime today;

  final String email;
  final String password;
  final String phone;
  final String code;

  /// When the last code was sent. Resending is allowed [resendCooldown]
  /// after this.
  final DateTime? codeSentAt;
  final bool resending;

  final String username;
  final String firstName;
  final String lastName;

  /// As typed, "dd-mm-yyyy".
  final String birthDate;
  final String? photoPath;

  /// Fields the user has left. Their errors show from then on.
  final Set<SignUpField> touched;

  /// Steps the user has tried to submit. Every error of the step shows.
  final Set<SignUpStep> attempted;

  /// The step that [status] and [failure] belong to. Each screen only
  /// reacts to its own step, so going back and submitting a step again
  /// works as expected.
  final SignUpStep step;
  final SignUpStatus status;
  final Failure? failure;

  static const resendCooldown = Duration(seconds: 30);

  EmailError? get emailError => CredentialValidators.email(email);
  PasswordError? get passwordError => CredentialValidators.password(password);
  PhoneError? get phoneError => SignUpValidators.phone(phone);
  UsernameError? get usernameError => SignUpValidators.username(username);
  NameError? get firstNameError => SignUpValidators.name(firstName);
  NameError? get lastNameError => SignUpValidators.name(lastName);
  BirthDateError? get birthDateError =>
      SignUpValidators.birthDate(birthDate, today: today);

  bool get credentialsValid => emailError == null && passwordError == null;
  bool get phoneValid => phoneError == null;
  bool get codeComplete => SignUpValidators.code(code) == null;
  bool get profileValid =>
      usernameError == null &&
      firstNameError == null &&
      lastNameError == null &&
      birthDateError == null;

  bool isSubmitting(SignUpStep s) =>
      step == s && status == SignUpStatus.submitting;

  Failure? failureFor(SignUpStep s) => step == s ? failure : null;

  DateTime? get resendAvailableAt => codeSentAt?.add(resendCooldown);

  EmailError? get visibleEmailError =>
      _visible(SignUpField.email) ? emailError : null;
  PasswordError? get visiblePasswordError =>
      _visible(SignUpField.password) ? passwordError : null;
  PhoneError? get visiblePhoneError =>
      _visible(SignUpField.phone) ? phoneError : null;
  UsernameError? get visibleUsernameError =>
      _visible(SignUpField.username) ? usernameError : null;
  NameError? get visibleFirstNameError =>
      _visible(SignUpField.firstName) ? firstNameError : null;
  NameError? get visibleLastNameError =>
      _visible(SignUpField.lastName) ? lastNameError : null;
  BirthDateError? get visibleBirthDateError =>
      _visible(SignUpField.birthDate) ? birthDateError : null;

  bool _visible(SignUpField field) =>
      attempted.contains(field.step) || touched.contains(field);

  SignUpState copyWith({
    String? email,
    String? password,
    String? phone,
    String? code,
    DateTime? codeSentAt,
    bool? resending,
    String? username,
    String? firstName,
    String? lastName,
    String? birthDate,
    String? Function()? photoPath,
    Set<SignUpField>? touched,
    Set<SignUpStep>? attempted,
    SignUpStep? step,
    SignUpStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SignUpState(
      today: today,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      codeSentAt: codeSentAt ?? this.codeSentAt,
      resending: resending ?? this.resending,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath != null ? photoPath() : this.photoPath,
      touched: touched ?? this.touched,
      attempted: attempted ?? this.attempted,
      step: step ?? this.step,
      status:
          status ??
          (clearFailure && this.status == SignUpStatus.failure
              ? SignUpStatus.editing
              : this.status),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    today,
    email,
    password,
    phone,
    code,
    codeSentAt,
    resending,
    username,
    firstName,
    lastName,
    birthDate,
    photoPath,
    touched,
    attempted,
    step,
    status,
    failure,
  ];
}
