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
        'ugly, blurry, low quality, distorted, deformed, disfigured, bad anatomy, watermark, grayscale, monochrome, dull colors, wrong object, incorrect object, low resolution',
  });

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

  Map<String, String> toJson() {
    return {
      'text_prompts[0][text]':
          '$basePrompt, enhance details, add vibrant colors, maintain original sketch structure, photorealistic, highly detailed, 8k resolution, sharp focus, professional-grade output',
      'text_prompts[0][weight]': '1',
      'text_prompts[1][text]': negativePrompt,
      'text_prompts[1][weight]': '-1',
      'cfg_scale': '35', // Lowered for better fine-tuning
      'clip_guidance_preset': 'FAST_BLUE',
      'style_preset': _getStylePreset(),
      'steps': '50',
      'init_image_mode': 'IMAGE_STRENGTH',
      'image_strength': '0.25', // Increased for better color adjustment
    };
  }
}
