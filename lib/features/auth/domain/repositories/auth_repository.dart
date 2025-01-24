import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> signUpWithEmailAndPassword(
      String email, String password, String username);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  });
  Future<void> deleteAccount();
  Stream<User?> get authStateChanges;
}
