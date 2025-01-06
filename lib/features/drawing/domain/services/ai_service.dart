import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/config/api_config.dart';

class AIService {
  static Future<String> generateImage(Uint8List imageBytes) async {
    try {
      // Multipart request oluştur
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.baseUrl + ApiConfig.imageToImageEndpoint),
      );

      // Headers ekle
      request.headers.addAll({
        'Authorization': 'Bearer ${ApiConfig.apiKey}',
        'Accept': 'application/json',
      });

      // Görüntüyü ekle
      request.files.add(
        http.MultipartFile.fromBytes(
          'init_image',
          imageBytes,
          filename: 'sketch.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Parametreleri ekle
      request.fields.addAll({
        'text_prompts[0][text]':
            'Transform this sketch into a ultra-realistic photograph. Add natural lighting, realistic shadows, and fine details. Create depth with professional photography techniques like bokeh and depth of field. Include realistic textures, materials, and surface details. Make it indistinguishable from a professional DSLR camera photo with perfect exposure and color grading. Style should match high-end photography magazines',
        'text_prompts[0][weight]': '1',
        'text_prompts[1][text]':
            'drawing, sketch, painting, illustration, cartoon, anime, digital art, artificial, unnatural, low quality, blurry, distorted, deformed, bad anatomy, bad perspective, amateur',
        'text_prompts[1][weight]': '-1',
        'cfg_scale': '10',
        'clip_guidance_preset': 'FAST_BLUE',
        'samples': '1',
        'steps': '50',
        'style_preset': 'photographic',
      });

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = data['artifacts'] as List;
        if (images.isNotEmpty) {
          final base64Image = images[0]['base64'] as String;
          return 'data:image/png;base64,$base64Image';
        }
        throw Exception('Görsel oluşturulamadı');
      } else {
        print('API Yanıtı: ${response.body}');
        throw Exception('API Hatası: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Hata Detayı: $e');
      throw Exception('AI servisi hatası: $e');
    }
  }

  static Future<String> saveGeneratedImage(
      String imageUrl, String fileName) async {
    try {
      // Base64 kısmını ayıkla
      final base64Image = imageUrl.split(',')[1];
      final bytes = base64Decode(base64Image);

      // Uygulama dökümanlar dizinini al
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/ai_images');

      // Dizin yoksa oluştur
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Dosya yolu oluştur
      final filePath = '${imagesDir.path}/$fileName';

      // Dosyayı kaydet
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Görsel kaydedilemedi: $e');
    }
  }
}
