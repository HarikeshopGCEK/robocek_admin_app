import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initializationError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    initializationError = error;
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(RobocekAdminApp(initializationError: initializationError));
}

class RobocekAdminApp extends StatelessWidget {
  final Object? initializationError;

  const RobocekAdminApp({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROBOCEK Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: initializationError == null
          ? const FirebaseReadyPage()
          : FirebaseErrorPage(error: initializationError!),
    );
  }
}

class FirebaseReadyPage extends StatelessWidget {
  const FirebaseReadyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ROBOCEK Admin')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done, size: 56),
            SizedBox(height: 16),
            Text('Firebase initialized successfully'),
          ],
        ),
      ),
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
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Firebase initialization failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Check your Firebase configuration and '
                'Android setup, then restart the app.',
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
