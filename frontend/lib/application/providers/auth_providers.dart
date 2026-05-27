import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String id;
  final String email;
  final bool isAdmin;
  final String? name;

  User({
    required this.id,
    required this.email,
    required this.isAdmin,
    this.name,
  });
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 300));

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
          isLoading: false, error: 'Email and password are required.');
      return;
    }

    final isAdmin = email.toLowerCase().contains('admin');
    final user = User(
      id: email,
      email: email,
      isAdmin: isAdmin,
      name: isAdmin ? 'Admin User' : 'Employee',
    );

    state = state.copyWith(user: user, isLoading: false, error: null);
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
