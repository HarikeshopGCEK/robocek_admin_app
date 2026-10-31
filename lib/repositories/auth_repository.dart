import 'package:firebase_auth/firebase_auth.dart';

const String kAdminEmail = 'robocek@gcek.ac.in';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAdminLoggedIn {
    final user = _auth.currentUser;
    return user != null && user.email?.trim().toLowerCase() == kAdminEmail;
  }

  Future<void> signIn(String email, String password) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed != kAdminEmail) {
      throw Exception('Unauthorized: Only $kAdminEmail can log in as Admin.');
    }
    await _auth.signInWithEmailAndPassword(email: trimmed, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
