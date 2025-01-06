# AI Çizim Uygulaması

Bu Flutter uygulaması, kullanıcıların çizimler yapmasına ve bu çizimleri yapay zeka ile gerçekçi görsellere dönüştürmesine olanak sağlar.

## Özellikler

- Serbest çizim yapabilme
- Farklı renk ve kalınlık seçenekleri
- Silgi aracı
- Geri alma özelliği
- Çizimleri kaydetme
- AI ile gerçekçi görsele dönüştürme
- Dönüştürülen görselleri kaydetme

## Kurulum

1. Flutter'ı yükleyin (https://flutter.dev/docs/get-started/install)
2. Repository'yi klonlayın
```bash
git clone https://github.com/KULLANICI_ADINIZ/REPO_ADINIZ.git
```
3. Bağımlılıkları yükleyin
```bash
flutter pub get
```
4. API anahtarınızı ayarlayın
   - `lib/core/config/api_config.dart` dosyası oluşturun
   - Aşağıdaki içeriği ekleyin:
```dart
class ApiConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String baseUrl = 'YOUR_API_BASE_URL';
  static const String imageToImageEndpoint = 'YOUR_ENDPOINT';
}
```

## Kullanım

1. Çizim yapmak için ekranı kullanın
2. Sol taraftaki araç çubuğundan renk ve kalınlık seçin
3. Çizimi kaydetmek için kaydet butonunu kullanın
4. AI dönüşümü için AI butonuna tıklayın
5. Oluşturulan görseli kaydetmek için kaydet butonunu kullanın

## Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.
