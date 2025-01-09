import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Drawing';

  @override
  String get drawingTab => 'Draw';

  @override
  String get galleryTab => 'Gallery';

  @override
  String get profileTab => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this drawing?';

  @override
  String get error => 'An error occurred';

  @override
  String get noDrawings => 'No drawings yet';

  @override
  String get allCategories => 'All';

  @override
  String createdAt(String date) {
    return 'Created at: $date';
  }

  @override
  String get remainingCredits => 'Remaining Credits';

  @override
  String credits(int count) {
    return '$count credits';
  }

  @override
  String get watchAdForCredit => 'Watch Ad for 1 Credit';

  @override
  String get watchAdLoading => 'Loading Ad...';

  @override
  String get creditPackages => 'Credit Packages';

  @override
  String get creditPackage10 => '10 Credits';

  @override
  String get creditPackage25 => '25 Credits';

  @override
  String get creditPackage50 => '50 Credits';

  @override
  String get buyNow => 'Buy Now';

  @override
  String purchaseConfirmation(int credits) {
    return 'Do you want to buy $credits credits?';
  }

  @override
  String purchaseSuccess(int credits) {
    return 'Successfully purchased $credits credits!';
  }

  @override
  String get purchaseError => 'Purchase failed';
}
