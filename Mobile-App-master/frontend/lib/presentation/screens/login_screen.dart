import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_providers.dart';
import '../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
            authState.user!.isAdmin ? '/admin' : '/employee');
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
           colors: [
            Color(0xFFD7F3EE),
            Color(0xFFEAF8F5),
            Color(0xFFFFFFFF),
       ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
  elevation: 10,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

const Icon(
  Icons.work_outline,
  size: 72,
  color: Color(0xFF0F766E),
),

const SizedBox(height: 16),

const Text(
  'WorkRoster',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F766E),
    letterSpacing: 1.2,
  ),
),

const SizedBox(height: 8),

const Text(
  'Manage schedules and employee shifts',
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Colors.black54,
    fontSize: 14,
  ),
),
                      const SizedBox(height: 24),
                      const Text('Email',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'Enter your email')),
                      const SizedBox(height: 14),
                      const Text('Password',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: 'Enter your password')),
                      const SizedBox(height: 18),
                      if (authState.error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.danger.withOpacity(0.24)),
                          ),
                          child: Text(authState.error!,
                              style: const TextStyle(color: AppTheme.danger)),
                        ),
                      SizedBox(
                       height: 52,
                      child: ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                await authNotifier.signIn(
                                    _emailController.text.trim(),
                                    _passwordController.text);
                              },
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                           : const Text(
                               'Sign In',
                              style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              ),
                           ),
                      ),
                      ),
 
                     const SizedBox(height: 16),
                      const Text('(c) 2026 WorkRoster',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
