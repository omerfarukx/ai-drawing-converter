import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ai_model.dart';

class AIServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  AIServiceException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    if (responseBody != null) {
      return 'AIServiceException: $message (Status: $statusCode)\nResponse: $responseBody';
    }
    return 'AIServiceException: $message (Status: $statusCode)';
  }
}

class AIService {
  static const String _baseUrl = 'https://api.stability.ai/v1';
  static const String _apiKey =
      'sk-47VPRkOkBYj5Cw2gjWEaDVI1A5HzNQrBzbtcESoSWTfHPPH7';

  static Future<String> generateImage(
    Uint8List imageBytes,
    AIModel model,
  ) async {
    try {
      // MultipartRequest oluştur
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$_baseUrl/generation/stable-diffusion-xl-1024-v1-0/image-to-image'),
      );

      // Headers ekle
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'application/json',
      });

      // Model parametrelerini ekle
      request.fields.addAll({
        'text_prompts[0][text]':
            '${model.basePrompt}, masterpiece, best quality, extremely detailed, ultra high resolution, professional, 8k uhd, perfect composition, well-balanced, full scene, no empty space',
        'text_prompts[0][weight]': '1',
        'text_prompts[1][text]':
            'ugly, blurry, low quality, distorted, deformed, disfigured, bad anatomy, watermark, signature, text, missing details, empty background, cropped, out of frame',
        'text_prompts[1][weight]': '-1',
        'cfg_scale': '12',
        'clip_guidance_preset': 'FAST_BLUE',
        'samples': '1',
        'steps': '50',
        'style_preset': _getStylePreset(model.modelType),
        'init_image_mode': 'IMAGE_STRENGTH',
        'image_strength': '0.10',
      });

      // Resmi ekle
      request.files.add(
        http.MultipartFile.fromBytes(
          'init_image',
          imageBytes,
          filename: 'drawing.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw AIServiceException(
          'Resim oluşturulamadı',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      final jsonResponse = json.decode(response.body);
      final List<dynamic> artifacts = jsonResponse['artifacts'];

      if (artifacts.isEmpty) {
        throw AIServiceException('Resim oluşturulamadı: Sonuç boş');
      }

      final resultImage = artifacts.first['base64'];
      if (resultImage == null || resultImage.isEmpty) {
        throw AIServiceException('Geçersiz görüntü verisi alındı');
      }

      return resultImage;
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('AI Servisi Hatası: $e');
    }
  }

  static String _getStylePreset(AIModelType modelType) {
    switch (modelType) {
      case AIModelType.realistic:
        return '3d-model';
      case AIModelType.cartoon:
        return 'cinematic';
      case AIModelType.anime:
        return 'anime';
      case AIModelType.sketch:
        return 'origami';
    }
  }

  // Test için mock fonksiyon
  static Future<String> mockGenerateImage(
    Uint8List imageBytes,
    AIModel model,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://picsum.photos/512';
  }

  static Future<String> saveImage(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      final directory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory('${directory.path}/images');

      if (!await imagesDirectory.exists()) {
        await imagesDirectory.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${imagesDirectory.path}/image_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Görsel kaydedilemedi: $e');
      throw AIServiceException('Görsel kaydedilemedi: ${e.toString()}');
    }
  }
}
