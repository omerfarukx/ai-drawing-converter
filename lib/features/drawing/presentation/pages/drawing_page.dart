import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/ai_button.dart';

class DrawingPage extends ConsumerWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.drawingTab),
      ),
      body: Stack(
        children: [
          const DrawingCanvas(),
          const Positioned(
            top: 16,
            right: 16,
            child: AiButton(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DrawingToolbar(),
          ),
        ],
      ),
    );
  }
}
