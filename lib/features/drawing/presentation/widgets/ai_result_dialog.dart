import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';

class AIResultDialog extends ConsumerWidget {
  final String imageUrl;

  const AIResultDialog({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.memory(
              base64Decode(imageUrl),
              fit: BoxFit.contain,
              width: 300,
              height: 300,
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  ref.read(aiProvider.notifier).clearImage();
                  Navigator.of(context).pop();
                },
                child: const Text('Kapat'),
              ),
              FilledButton(
                onPressed: () {
                  // TODO: Save image
                  Navigator.of(context).pop();
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
