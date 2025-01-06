import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
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
      request.fields.addAll(model.toJson());

      // Resmi ekle
      request.files.add(
        http.MultipartFile.fromBytes(
          'init_image',
          imageBytes,
          filename: 'drawing.png',
        ),
      );

      print('İstek gönderiliyor...');
      print('Request fields: ${request.fields}');

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Yanıt alındı: ${response.statusCode}');
      print('Yanıt body: ${response.body}');

      // Yanıtı kontrol et
      if (response.statusCode != 200) {
        throw AIServiceException(
          'Resim oluşturulamadı',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      // Yanıtı parse et
      final jsonResponse = json.decode(response.body);
      final List<dynamic> artifacts = jsonResponse['artifacts'];

      if (artifacts.isEmpty) {
        throw AIServiceException('Resim oluşturulamadı: Sonuç boş');
      }

      return artifacts.first['base64'];
    } catch (e) {
      print('Hata oluştu: $e');
      if (e is AIServiceException) rethrow;
      throw AIServiceException(
        'Beklenmeyen bir hata oluştu: ${e.toString()}',
      );
    }
  }
}
