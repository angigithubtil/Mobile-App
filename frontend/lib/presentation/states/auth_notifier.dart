import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String? userId;
  final String? email;
  final bool isAdmin;
  final bool isLoading;
  final String? error;

  AuthState({
    this.userId,
    this.email,
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? userId,
    String? email,
    bool? isAdmin,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void login(String userId, String email, bool isAdmin) {
    state = state.copyWith(
      userId: userId,
      email: email,
      isAdmin: isAdmin,
    );
  }

  void logout() {
    state = AuthState();
  }
}
