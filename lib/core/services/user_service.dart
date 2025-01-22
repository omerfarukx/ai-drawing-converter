import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserService {
  static const String _firstLoginKey = 'first_login';
  static const String _creditsKey = 'user_credits';
  static const String _firstPurchaseKey = 'first_purchase';
  static const String _userIdKey = 'user_id';
  static const String _lastSpecialOfferKey = 'last_special_offer';
  static const int _initialCredits = 5;

  late final SharedPreferences _prefs;
  final _uuid = const Uuid();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  UserService._internal();

  // Initialize
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Mevcut kullanıcıyı getir
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Google ile giriş yap
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google ile giriş hatası: $e');
      return null;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // İlk giriş kontrolü ve kredi verme
  Future<void> checkFirstLogin() async {
    final isFirstLogin = !(_prefs.getBool(_firstLoginKey) ?? false);
    if (isFirstLogin) {
      await _prefs.setBool(_firstLoginKey, true);
      await addCredits(_initialCredits);
      await _initializeUserId();
    }
  }

  // Kullanıcı ID'si oluşturma
  Future<void> _initializeUserId() async {
    if (!_prefs.containsKey(_userIdKey)) {
      final userId = _uuid.v4();
      await _prefs.setString(_userIdKey, userId);
    }
  }

  // Kredi ekleme
  Future<void> addCredits(int amount) async {
    final currentCredits = await getCredits();
    await _prefs.setInt(_creditsKey, currentCredits + amount);
  }

  // Kredi çıkarma
  Future<bool> useCredits(int amount) async {
    final currentCredits = await getCredits();
    if (currentCredits >= amount) {
      await _prefs.setInt(_creditsKey, currentCredits - amount);
      return true;
    }
    return false;
  }

  // Mevcut kredileri getirme
  Future<int> getCredits() async {
    return _prefs.getInt(_creditsKey) ?? 0;
  }

  // İlk satın alma kontrolü
  Future<bool> isFirstPurchase() async {
    return !(_prefs.getBool(_firstPurchaseKey) ?? false);
  }

  // İlk satın alma işaretleme
  Future<void> markFirstPurchaseUsed() async {
    await _prefs.setBool(_firstPurchaseKey, true);
  }

  // Özel teklif kontrolü
  Future<bool> shouldShowSpecialOffer() async {
    final lastOffer = _prefs.getInt(_lastSpecialOfferKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastOffer) >= const Duration(days: 7).inMilliseconds;
  }

  // Özel teklif gösterildi işaretle
  Future<void> markSpecialOfferShown() async {
    await _prefs.setInt(
        _lastSpecialOfferKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Arkadaş davet etme
  Future<void> inviteFriend() async {
    await FlutterShare.share(
      title: 'AI ile Çizim Uygulaması',
      text:
          'Yapay zeka ile harika çizimler yapabileceğin bu uygulamayı dene! Benim davet kodum: ${await _getUserId()}',
      linkUrl:
          'https://play.google.com/store/apps/details?id=com.yapayzeka.cizim',
    );
  }

  // Davet kodu ile gelen kullanıcı
  Future<void> handleInviteCode(String inviteCode) async {
    if (inviteCode.isNotEmpty && inviteCode != await _getUserId()) {
      await addCredits(2);
    }
  }

  Future<String> _getUserId() async {
    return _prefs.getString(_userIdKey) ?? '';
  }
}
