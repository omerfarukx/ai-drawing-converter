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
    Uint8List imageBytes, {
    required AIModel model,
  }) async {
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
      final modelJson = model.toJson();
      modelJson['text_prompts'].asMap().forEach((index, prompt) {
        request.fields['text_prompts[$index][text]'] = prompt['text'];
        request.fields['text_prompts[$index][weight]'] =
            prompt['weight'].toString();
      });

      request.fields['cfg_scale'] = modelJson['cfg_scale'].toString();
      request.fields['clip_guidance_preset'] =
          modelJson['clip_guidance_preset'];
      request.fields['style_preset'] = modelJson['style_preset'];
      request.fields['samples'] = modelJson['samples'].toString();
      request.fields['steps'] = modelJson['steps'].toString();
      request.fields['init_image_mode'] = modelJson['init_image_mode'];
      request.fields['image_strength'] = modelJson['image_strength'].toString();

      // Resmi ekle
      request.files.add(
        http.MultipartFile.fromBytes(
          'init_image',
          imageBytes,
          filename: 'drawing.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      print('İstek gönderiliyor...');
      print('Request fields: ${request.fields}');

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Yanıt alındı: ${response.statusCode}');
      print('Yanıt body: ${response.body}');

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

      try {
        // Base64'ü doğrula
        final decodedImage = base64Decode(resultImage);
        if (decodedImage.isEmpty) {
          throw AIServiceException('Görüntü verisi boş');
        }

        // Görüntüyü kaydet
        final imagePath = await saveImage(resultImage);
        print('Görüntü kaydedildi: $imagePath');

        return resultImage;
      } catch (e) {
        print('Görüntü işleme hatası: $e');
        throw AIServiceException('Görüntü işlenemedi: ${e.toString()}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
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
