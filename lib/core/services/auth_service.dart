import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _lastSignInAttempt;
  int _signInAttempts = 0;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Şifre ile kayıt
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email/Şifre ile giriş
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('Debug: Giriş denemesi başlatılıyor...');
      print('Debug: Email: $email');
      print('Debug: Mevcut kullanıcı: ${_auth.currentUser?.uid}');
      print(
          'Debug: Auth durumu: ${_auth.currentUser != null ? 'Oturum açık' : 'Oturum kapalı'}');

      // Rate limiting kontrolü
      final now = DateTime.now();
      if (_lastSignInAttempt != null) {
        final difference = now.difference(_lastSignInAttempt!);
        print(
            'Debug: Son denemeden bu yana geçen süre: ${difference.inMinutes} dakika');
        print('Debug: Deneme sayısı: $_signInAttempts');

        if (_signInAttempts >= 10 && difference.inMinutes < 5) {
          print('Debug: Çok fazla deneme yapıldı. 5 dakika beklenmeli.');
          throw FirebaseAuthException(
            code: 'too-many-requests',
            message:
                'Çok fazla giriş denemesi yapıldı. Lütfen 5 dakika bekleyin.',
          );
        } else if (difference.inMinutes >= 5) {
          print('Debug: Bekleme süresi doldu, sayaç sıfırlanıyor');
          _signInAttempts = 0;
        }
      }

      _lastSignInAttempt = now;
      _signInAttempts++;

      print('Debug: Firebase ile giriş yapılıyor...');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Başarılı girişte sayacı sıfırla
      _signInAttempts = 0;
      print('Debug: Giriş başarılı - UserId: ${result.user?.uid}');
      print('Debug: Email doğrulanmış mı: ${result.user?.emailVerified}');
      return result;
    } catch (e) {
      print('Debug: Giriş hatası detayı:');
      print('Debug: Hata tipi: ${e.runtimeType}');
      print('Debug: Hata mesajı: $e');
      if (e is FirebaseAuthException) {
        print('Debug: Firebase hata kodu: ${e.code}');
        print('Debug: Firebase hata mesajı: ${e.message}');
        print('Debug: Firebase credential: ${e.credential}');
      }

      if (e is FirebaseAuthException && e.code == 'too-many-requests') {
        _signInAttempts = 5;
      }
      throw _handleAuthException(e);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Şifre sıfırlama emaili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Hata yönetimi
  String _handleAuthException(dynamic e) {
    print('Debug: Auth hatası yakalandı - ${e.runtimeType}: $e');
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'Şifre en az 6 karakter olmalıdır.';
        case 'email-already-in-use':
          return 'Bu email adresi zaten kullanımda.';
        case 'user-not-found':
          return 'Bu email adresiyle kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Email veya şifre hatalı.';
        case 'invalid-email':
          return 'Geçersiz email adresi.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        case 'operation-not-allowed':
          return 'Email/şifre girişi devre dışı bırakılmış.';
        case 'too-many-requests':
          final remainingMinutes =
              5 - DateTime.now().difference(_lastSignInAttempt!).inMinutes;
          return 'Çok fazla giriş denemesi yapıldı. Lütfen ${remainingMinutes > 0 ? '$remainingMinutes dakika' : 'biraz'} bekleyin.';
        case 'network-request-failed':
          return 'İnternet bağlantınızı kontrol edin.';
        default:
          return 'Giriş yapılırken bir hata oluştu: ${e.message}';
      }
    }
    return 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  }
}
