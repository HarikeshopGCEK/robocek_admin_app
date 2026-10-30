import 'package:flutter/material.dart';

import '../features/dashboard/admin_shell.dart';
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
          ? const AdminShell()
          : FirebaseErrorPage(error: initializationError!),
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
