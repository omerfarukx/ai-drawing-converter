import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      // Null kontrolü ekleyerek veriyi dönüştür
      return User(
        id: data['id'] as String? ?? '',
        email: data['email'] as String? ?? '',
        username: data['username'] as String? ?? '',
        displayName: data['displayName'] as String?,
        photoURL: data['photoURL'] as String?,
        bio: data['bio'] as String?,
        followers: List<String>.from(data['followers'] ?? []),
        following: List<String>.from(data['following'] ?? []),
        drawingsCount: data['drawingsCount'] as int? ?? 0,
        isVerified: data['isVerified'] as bool? ?? false,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null,
        lastLoginAt: data['lastLoginAt'] != null
            ? (data['lastLoginAt'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      print('getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Firebase Auth ile giriş yap
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Firestore'dan kullanıcı bilgilerini al
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      // Eğer kullanıcı Firestore'da yoksa, yeni profil oluştur
      if (!doc.exists || doc.data() == null) {
        final newUser = User(
          id: credential.user!.uid,
          email: email,
          username: email.split('@')[0], // Geçici kullanıcı adı
          displayName: 'Yeni Kullanıcı',
          photoURL: null,
          bio: 'Merhaba! Ben yeni bir kullanıcıyım.',
          followers: [],
          following: [],
          drawingsCount: 0,
          isVerified: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Yeni kullanıcıyı Firestore'a kaydet
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toJson());

        return newUser;
      }

      // Mevcut kullanıcı verilerini dönüştür
      final data = doc.data()!;
      return User(
        id: credential.user!.uid,
        email: email,
        username: data['username'] as String? ?? email.split('@')[0],
        displayName: data['displayName'] as String? ?? 'Yeni Kullanıcı',
        photoURL: data['photoURL'] as String?,
        bio: data['bio'] as String? ?? 'Merhaba! Ben yeni bir kullanıcıyım.',
        followers: List<String>.from(data['followers'] ?? []),
        following: List<String>.from(data['following'] ?? []),
        drawingsCount: (data['drawingsCount'] as num?)?.toInt() ?? 0,
        isVerified: data['isVerified'] as bool? ?? false,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Bu email ile kayıtlı kullanıcı bulunamadı');
        case 'wrong-password':
          throw Exception('Hatalı şifre');
        case 'invalid-email':
          throw Exception('Geçersiz email adresi');
        case 'user-disabled':
          throw Exception('Bu hesap devre dışı bırakılmış');
        default:
          throw Exception('Giriş yapılırken bir hata oluştu: ${e.message}');
      }
    } catch (e) {
      throw Exception('Giriş yapılırken beklenmeyen bir hata oluştu: $e');
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Check if username is already taken
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('Bu kullanıcı adı zaten kullanılıyor');
      }

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      // Varsayılan profil bilgileri
      final user = User(
        id: credential.user!.uid,
        email: email,
        username: username,
        displayName: 'Yeni Kullanıcı',
        photoURL: null,
        bio: 'Merhaba! Ben yeni bir kullanıcıyım.',
        followers: [],
        following: [],
        drawingsCount: 0,
        isVerified: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Kullanıcı bilgilerini Firestore'a kaydet
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Kayıt olurken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapılırken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(
          'Şifre sıfırlama e-postası gönderilirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (bio != null) updates['bio'] = bio;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw Exception('Profil güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');

      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    } catch (e) {
      throw Exception('Hesap silinirken bir hata oluştu: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!doc.exists) return null;

        final data = doc.data();
        if (data == null) return null;

        return User(
          id: data['id'] as String? ?? firebaseUser.uid,
          email: data['email'] as String? ?? firebaseUser.email ?? '',
          username: data['username'] as String? ?? '',
          displayName: data['displayName'] as String?,
          photoURL: data['photoURL'] as String?,
          bio: data['bio'] as String?,
          followers: List<String>.from(data['followers'] ?? []),
          following: List<String>.from(data['following'] ?? []),
          drawingsCount: data['drawingsCount'] as int? ?? 0,
          isVerified: data['isVerified'] as bool? ?? false,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.parse(data['createdAt'] as String))
              : DateTime.now(),
          lastLoginAt: data['lastLoginAt'] != null
              ? (data['lastLoginAt'] is Timestamp
                  ? (data['lastLoginAt'] as Timestamp).toDate()
                  : DateTime.parse(data['lastLoginAt'] as String))
              : DateTime.now(),
        );
      } catch (e) {
        print('authStateChanges error: $e');
        return null;
      }
    });
  }
}
