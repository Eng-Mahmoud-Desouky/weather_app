import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import '../../data/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  // ToDo: Search about StreamSubscription
  StreamSubscription<UserModel?>? _authStateSubscription;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    _monitorAuthState();
  }
  void _monitorAuthState() {
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthError('Please fill in all fields'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _authRepository.signIn(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      emit(const AuthError('Please fill in all fields'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthError('Password must be at least 6 characters long'));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUp(email, password, name);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Check auth status when the app starts
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
