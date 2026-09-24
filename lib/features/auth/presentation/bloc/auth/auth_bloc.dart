import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:tm30_pay/features/auth/domain/auth_repository.dart';
import 'package:tm30_pay/features/auth/domain/auth_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Holds the signed-in user for the whole app. The router watches this
/// bloc to decide whether to show sign-in or the wallet, and screens read
/// the user's profile from it.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authRepository, required AuthUser? initialUser})
    : super(AuthState(initialUser)) {
    on<AuthSubscriptionRequested>(
      _onSubscriptionRequested,
      transformer: restartable(),
    );
    on<AuthSignOutRequested>(_onSignOutRequested, transformer: droppable());
  }

  final AuthRepository _authRepository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    // emit.forEach cancels the stream subscription automatically when the
    // bloc closes, so no StreamSubscription needs to be managed by hand.
    return emit.forEach(_authRepository.userChanges, onData: AuthState.new);
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) => _authRepository.signOut();
}
