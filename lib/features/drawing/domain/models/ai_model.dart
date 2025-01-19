import 'package:flutter/material.dart';

enum AIModelType {
  realistic,
  cartoon,
  anime,
  sketch;

  String get prompt {
    switch (this) {
      case AIModelType.realistic:
        return 'transform this drawing into a highly detailed, photorealistic digital art with rich textures, volumetric lighting, dynamic shadows, and intricate details. Add atmospheric effects, detailed environment, and enhance all elements to create a complete and immersive scene';
      case AIModelType.cartoon:
        return 'transform this drawing into a vibrant, fully detailed cartoon artwork with rich colors, dynamic shading, expressive characters, detailed backgrounds, and atmospheric effects. Add complementary elements to fill the scene naturally, maintaining a cohesive cartoon style';
      case AIModelType.anime:
        return 'transform this drawing into a detailed anime illustration with vibrant colors, dramatic lighting, detailed backgrounds, and distinctive anime art style. Add atmospheric effects, environmental details, and enhance the composition to create a complete anime scene';
      case AIModelType.sketch:
        return 'transform this drawing into a highly detailed artistic sketch with intricate line work, rich texturing, dynamic shading, and atmospheric depth. Add complementary elements and background details to create a complete and balanced composition';
    }
  }
}

class AIModel {
  final AIModelType modelType;
  final String basePrompt;
  final Map<String, dynamic>? parameters;

  const AIModel({
    required this.modelType,
    required this.basePrompt,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'model_type': modelType.name,
      'prompt': basePrompt,
      'parameters': parameters ?? {},
    };
  }
}
