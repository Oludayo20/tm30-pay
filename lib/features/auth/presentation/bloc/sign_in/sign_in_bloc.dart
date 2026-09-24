import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/auth_repository.dart';
import '../../../domain/credential_validators.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc({required this._authRepository}) : super(const SignInState()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInFieldBlurred>(_onFieldBlurred);
    // droppable() ignores any extra submit events while one is still being
    // handled, so a double tap cannot sign in twice.
    on<SignInSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) =>
      emit(state.copyWith(email: event.email, clearFailure: true));

  void _onPasswordChanged(
    SignInPasswordChanged event,
    Emitter<SignInState> emit,
  ) => emit(state.copyWith(password: event.password, clearFailure: true));

  void _onFieldBlurred(SignInFieldBlurred event, Emitter<SignInState> emit) =>
      emit(state.copyWith(touched: {...state.touched, event.field}));

  Future<void> _onSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    // droppable() only covers the time while this handler runs. This check
    // also stops a tap that arrives after sign-in has already succeeded.
    if (state.isSubmitting || state.status == SignInStatus.success) return;
    emit(state.copyWith(submitAttempted: true, clearFailure: true));
    if (!state.isValid) return;

    emit(state.copyWith(status: SignInStatus.submitting));
    final result = await _authRepository.signIn(
      email: state.email,
      password: state.password,
    );
    // No navigation happens here. The repository reports the new status,
    // AuthBloc updates, and the router redirects.
    emit(switch (result) {
      Ok() => state.copyWith(status: SignInStatus.success),
      Err(:final failure) => state.copyWith(
        status: SignInStatus.failure,
        failure: failure,
      ),
    });
  }
}
