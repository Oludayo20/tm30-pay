import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/auth_repository.dart';
import '../../../domain/credential_validators.dart';
import '../../../domain/sign_up_details.dart';
import '../../../domain/sign_up_validators.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

/// Drives the whole sign-up flow: email and password, phone number, code
/// verification and profile. It lives for as long as the auth screens are
/// shown (see the router), so every step reads and adds to the same draft.
///
/// Like SignInBloc it never navigates to the wallet. After the final step
/// the repository announces the new user, AuthBloc updates and the router
/// redirects. Between steps, each screen moves to the next one when its
/// own step reaches [SignUpStatus.success].
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc({required this._authRepository, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(SignUpState(today: _dateOnly((clock ?? DateTime.now)()))) {
    on<SignUpStarted>(_onStarted);
    on<SignUpEmailChanged>(
      (e, emit) => emit(state.copyWith(email: e.email, clearFailure: true)),
    );
    on<SignUpPasswordChanged>(
      (e, emit) =>
          emit(state.copyWith(password: e.password, clearFailure: true)),
    );
    on<SignUpFieldBlurred>(
      (e, emit) => emit(state.copyWith(touched: {...state.touched, e.field})),
    );
    on<SignUpPhoneChanged>(
      (e, emit) => emit(state.copyWith(phone: e.phone, clearFailure: true)),
    );
    on<SignUpCodeChanged>(
      (e, emit) => emit(state.copyWith(code: e.code, clearFailure: true)),
    );
    on<SignUpUsernameChanged>(
      (e, emit) => emit(state.copyWith(username: e.username)),
    );
    on<SignUpFirstNameChanged>(
      (e, emit) => emit(state.copyWith(firstName: e.firstName)),
    );
    on<SignUpLastNameChanged>(
      (e, emit) => emit(state.copyWith(lastName: e.lastName)),
    );
    on<SignUpBirthDateChanged>(
      (e, emit) => emit(state.copyWith(birthDate: e.birthDate)),
    );
    on<SignUpPhotoChanged>(
      (e, emit) => emit(state.copyWith(photoPath: () => e.photoPath)),
    );
    // droppable() ignores extra taps while a step is being submitted.
    on<SignUpCredentialsSubmitted>(
      _onCredentialsSubmitted,
      transformer: droppable(),
    );
    on<SignUpCodeRequested>(_onCodeRequested, transformer: droppable());
    on<SignUpCodeResent>(_onCodeResent, transformer: droppable());
    on<SignUpCodeSubmitted>(_onCodeSubmitted, transformer: droppable());
    on<SignUpProfileSubmitted>(_onProfileSubmitted, transformer: droppable());
  }

  final AuthRepository _authRepository;
  final DateTime Function() _clock;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _onStarted(SignUpStarted event, Emitter<SignUpState> emit) =>
      emit(SignUpState(today: _dateOnly(_clock())));

  /// Marks [step] as attempted and resets its status. Returns false if the
  /// step's fields are invalid, in which case their errors now show.
  bool _begin(SignUpStep step, bool valid, Emitter<SignUpState> emit) {
    emit(
      state.copyWith(
        attempted: {...state.attempted, step},
        step: step,
        status: SignUpStatus.editing,
        clearFailure: true,
      ),
    );
    return valid;
  }

  void _onCredentialsSubmitted(
    SignUpCredentialsSubmitted event,
    Emitter<SignUpState> emit,
  ) {
    if (!_begin(SignUpStep.credentials, state.credentialsValid, emit)) return;
    // Nothing to send yet: the account is created once, after the profile.
    emit(state.copyWith(status: SignUpStatus.success));
  }

  Future<void> _onCodeRequested(
    SignUpCodeRequested event,
    Emitter<SignUpState> emit,
  ) async {
    if (state.isSubmitting(SignUpStep.phone)) return;
    if (!_begin(SignUpStep.phone, state.phoneValid, emit)) return;
    emit(state.copyWith(status: SignUpStatus.submitting));
    final result = await _authRepository.requestOtp(
      phone: SignUpValidators.normalisePhone(state.phone),
    );
    emit(switch (result) {
      Ok() => state.copyWith(
        status: SignUpStatus.success,
        code: '',
        codeSentAt: _clock(),
      ),
      Err(:final failure) => state.copyWith(
        status: SignUpStatus.failure,
        failure: failure,
      ),
    });
  }

  Future<void> _onCodeResent(
    SignUpCodeResent event,
    Emitter<SignUpState> emit,
  ) async {
    final availableAt = state.resendAvailableAt;
    if (availableAt != null && _clock().isBefore(availableAt)) return;
    emit(
      state.copyWith(
        resending: true,
        code: '',
        step: SignUpStep.verify,
        status: SignUpStatus.editing,
        clearFailure: true,
      ),
    );
    final result = await _authRepository.requestOtp(
      phone: SignUpValidators.normalisePhone(state.phone),
    );
    emit(switch (result) {
      Ok() => state.copyWith(resending: false, codeSentAt: _clock()),
      Err(:final failure) => state.copyWith(
        resending: false,
        status: SignUpStatus.failure,
        failure: failure,
      ),
    });
  }

  Future<void> _onCodeSubmitted(
    SignUpCodeSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (!_begin(SignUpStep.verify, state.codeComplete, emit)) return;
    emit(state.copyWith(status: SignUpStatus.submitting));
    final result = await _authRepository.verifyOtp(
      phone: SignUpValidators.normalisePhone(state.phone),
      code: state.code,
    );
    emit(switch (result) {
      Ok() => state.copyWith(status: SignUpStatus.success),
      Err(:final failure) => state.copyWith(
        status: SignUpStatus.failure,
        failure: failure,
        code: '',
      ),
    });
  }

  Future<void> _onProfileSubmitted(
    SignUpProfileSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    // Also stops a tap that lands after the account was created, while the
    // router is still moving to the wallet.
    if (state.step == SignUpStep.profile &&
        state.status == SignUpStatus.success) {
      return;
    }
    if (!_begin(SignUpStep.profile, state.profileValid, emit)) return;
    emit(state.copyWith(status: SignUpStatus.submitting));
    final result = await _authRepository.signUp(
      SignUpDetails(
        email: state.email,
        password: state.password,
        phone: SignUpValidators.normalisePhone(state.phone),
        username: state.username,
        firstName: state.firstName,
        lastName: state.lastName,
        dateOfBirth: SignUpValidators.parseBirthDate(state.birthDate)!,
        photoPath: state.photoPath,
      ),
    );
    emit(switch (result) {
      Ok() => state.copyWith(status: SignUpStatus.success),
      Err(:final failure) => state.copyWith(
        status: SignUpStatus.failure,
        failure: failure,
      ),
    });
  }
}
