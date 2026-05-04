import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleSignInRequested>(_onGoogle);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final token = _authRepository.getToken();
    if (token == null || token.isEmpty) {
      return emit(AuthUnauthenticated());
    }

    final cachedUser = await _authRepository.getCurrentUser();
    final role = _authRepository.getRole() ?? 'user';

    if (cachedUser != null) {
      emit(AuthAuthenticated(cachedUser, role));
    } else {
      emit(AuthLoading());
    }

    try {
      final user = await _authRepository.refreshUserFromServer();
      final latestRole = user.role ?? 'user';
      await _authRepository.saveRole(latestRole);

      emit(AuthAuthenticated(user, latestRole));
    } catch (e) {
      if (cachedUser == null) {
        emit(AuthUnauthenticated());
      }
    }
  }

  Future<void> _onLogin(event, emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user, user.role ?? "user"));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  Future<void> _onRegister(event, emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user, user.role));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  Future<void> _onGoogle(event, emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.googleSignIn(event.idToken);
      emit(AuthAuthenticated(user, user.role));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  Future<void> _onLogout(event, emit) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  String _cleanError(e) {
    return e.toString().replaceAll("Exception: ", "");
  }
}
