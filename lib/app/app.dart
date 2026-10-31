import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/login_page.dart';
import '../features/dashboard/admin_shell.dart';
import '../repositories/auth_repository.dart';
import 'theme.dart';

class RobocekAdminApp extends StatelessWidget {
  final Object? initializationError;

  const RobocekAdminApp({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBOCEK Admin',
      debugShowCheckedModeBanner: false,
      theme: buildRobocekTheme(),
      home: initializationError == null
          ? const _AuthGate()
          : FirebaseErrorPage(error: initializationError!),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authRepo.authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user != null && user.email?.trim().toLowerCase() == kAdminEmail) {
          return const AdminShell();
        }
        return const LoginPage();
      },
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  final Object error;

  const FirebaseErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase initialization failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Check your Firebase configuration and Android setup, '
                'then restart the app.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SelectableText(error.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
