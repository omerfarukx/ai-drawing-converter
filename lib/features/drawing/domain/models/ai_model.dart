import 'package:flutter/material.dart';

enum AIModelType {
  realistic,
  artistic,
  cartoon,
  anime,
  sketch,
}

class AIModel {
  final AIModelType modelType;
  final String basePrompt;
  final String negativePrompt;

  AIModel({
    required this.modelType,
    required this.basePrompt,
    this.negativePrompt =
        'ugly, blurry, low quality, distorted, deformed, disfigured, bad anatomy, watermark, grayscale, monochrome, dull colors, wrong object, incorrect object, low resolution, poor composition, overexposure, underexposure',
  });

  /// Returns the style preset based on the model type.
  String _getStylePreset() {
    switch (modelType) {
      case AIModelType.realistic:
        return 'photographic';
      case AIModelType.artistic:
        return 'artistic';
      case AIModelType.cartoon:
        return 'cartoon';
      case AIModelType.anime:
        return 'anime';
      case AIModelType.sketch:
        return 'sketch';
      default:
        return 'photographic';
    }
  }

  /// Generates the final prompt with enhancements based on the model type.
  String _enhanceBasePrompt() {
    switch (modelType) {
      case AIModelType.realistic:
        return '''
Transform this sketch into an ultra-realistic masterpiece. Add professional lighting, realistic shadows, fine textures, and natural details. 
Ensure the image appears as a professional DSLR camera photo with perfect color grading, vibrant tones, and stunning depth.
        ''';
      case AIModelType.artistic:
        return '''
Create a visually captivating artistic interpretation of this sketch. Use vibrant colors, dramatic lighting, and imaginative textures. 
Ensure the result reflects an artistic masterpiece with a touch of creativity and elegance.
        ''';
      case AIModelType.cartoon:
        return '''
Transform this sketch into a playful and lively cartoon. Add bold outlines, bright colors, and exaggerated features while maintaining a fun and engaging style.
        ''';
      case AIModelType.anime:
        return '''
Turn this sketch into an anime-inspired scene. Use rich and vibrant colors, dynamic shading, and intricate character details, ensuring a striking and immersive anime aesthetic.
        ''';
      case AIModelType.sketch:
        return '''
Refine this sketch with clean, sharp lines and enhanced details. Maintain its raw artistic essence while improving clarity and precision.
        ''';
      default:
        return basePrompt;
    }
  }

  /// Converts the AIModel instance to a JSON object for API requests.
  Map<String, dynamic> toJson() {
    return {
      'text_prompts': [
        {
          'text':
              '${_enhanceBasePrompt()}, high quality, highly detailed, sharp focus, 8k resolution, professional finish',
          'weight': 1
        },
        {'text': negativePrompt, 'weight': -1}
      ],
      'cfg_scale': 12,
      'clip_guidance_preset': 'FAST_BLUE',
      'style_preset': _getStylePreset(),
      'samples': 1,
      'steps': 50,
      'init_image_mode': 'IMAGE_STRENGTH',
      'image_strength': 0.25, // bunu elleme sakın
    };
  }
}
