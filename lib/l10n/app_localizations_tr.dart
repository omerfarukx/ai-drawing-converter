import 'app_localizations.dart';

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'AI Çizim';

  @override
  String get drawingTab => 'Çizim';

  @override
  String get galleryTab => 'Galeri';

  @override
  String get profileTab => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get deleteConfirmation => 'Bu çizimi silmek istediğinizden emin misiniz?';

  @override
  String get error => 'Bir hata oluştu';

  @override
  String get noDrawings => 'Henüz çizim yok';

  @override
  String get allCategories => 'Tümü';

  @override
  String createdAt(String date) {
    return 'Oluşturulma: $date';
  }

  @override
  String get remainingCredits => 'Kalan Haklar';

  @override
  String credits(int count) {
    return '$count hak';
  }

  @override
  String get watchAdForCredit => '1 Hak için Reklam İzle';

  @override
  String get watchAdLoading => 'Reklam Yükleniyor...';

  @override
  String get creditPackages => 'Kredi Paketleri';

  @override
  String get creditPackage10 => '10 Kredi';

  @override
  String get creditPackage25 => '25 Kredi';

  @override
  String get creditPackage50 => '50 Kredi';

  @override
  String get buyNow => 'Satın Al';

  @override
  String purchaseConfirmation(int credits) {
    return '$credits kredi satın almak istiyor musunuz?';
  }

  @override
  String purchaseSuccess(int credits) {
    return '$credits kredi başarıyla satın alındı!';
  }

  @override
  String get purchaseError => 'Satın alma başarısız oldu';
}
