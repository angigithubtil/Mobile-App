import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';

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

    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Email and password are required.',
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        state = state.copyWith(
          isLoading: false,
          error: body['message'] ?? 'Sign in failed.',
        );
        return;
      }

      final employee = body['employee'] as Map<String, dynamic>?;
      if (employee == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid response from server.',
        );
        return;
      }

      final user = User(
        id: employee['id']?.toString() ?? employee['_id']?.toString() ?? email,
        email: employee['email']?.toString() ?? email,
        isAdmin: employee['isAdmin'] == true,
        name: employee['name']?.toString() ?? employee['email']?.toString(),
      );

      state = state.copyWith(user: user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to connect to the server. Please start the backend.',
      );
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
