import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);

  yield const AuthState.loading();

  await for (final user in repository.authStateChanges) {
    if (user != null) {
      yield AuthState.authenticated(user);
    } else {
      yield const AuthState.unauthenticated();
    }
  }
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState.initial()) {
    // Auth durumunu dinle
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      final user =
          await _repository.signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signUpWithEmailAndPassword(
          email, password, username);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.sendPasswordResetEmail(email);
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      state = const AuthState.loading();
      await _repository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
        bio: bio,
      );
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = const AuthState.loading();
      await _repository.deleteAccount();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
