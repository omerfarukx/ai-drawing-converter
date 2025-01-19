import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_provider.dart';
import '../../domain/services/drawing_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final toolbarExpandedProvider = StateProvider<bool>((ref) => true);

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key});

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    try {
      final size = MediaQuery.of(context).size;
      final points = ref.read(drawingProvider).allPoints;

      if (points.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Önce bir şeyler çizmelisiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final filePath = await DrawingService.saveDrawingToFile(points, size);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çizim başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isExpanded = ref.watch(toolbarExpandedProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Genişletme/Daraltma butonu
          GestureDetector(
            onTap: () {
              ref.read(toolbarExpandedProvider.notifier).state = !isExpanded;
            },
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Üst sıra - Araçlar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: drawingState.canUndo
                    ? () => ref.read(drawingProvider.notifier).undo()
                    : null,
                tooltip: l10n.undo,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: drawingState.canRedo
                    ? () => ref.read(drawingProvider.notifier).redo()
                    : null,
                tooltip: l10n.redo,
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () => _showColorPicker(context, ref),
                tooltip: l10n.changeColor,
              ),
              IconButton(
                icon: const Icon(Icons.brush),
                onPressed: () => _showBrushSettings(context, ref),
                tooltip: l10n.brushSettings,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(drawingProvider.notifier).clear(),
                tooltip: l10n.clear,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => _handleSave(context, ref),
                tooltip: l10n.save,
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            // Kalınlık Ayarı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    l10n.brushSize,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: drawingState.strokeWidth,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: drawingState.strokeWidth.round().toString(),
                    onChanged: (value) {
                      ref.read(drawingProvider.notifier).setStrokeWidth(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Renk Seçimi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildColorButton(
                    context: context,
                    color: Colors.black,
                    isSelected: drawingState.selectedColor == Colors.black,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.black),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.red,
                    isSelected: drawingState.selectedColor == Colors.red,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.red),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.blue,
                    isSelected: drawingState.selectedColor == Colors.blue,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.blue),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.green,
                    isSelected: drawingState.selectedColor == Colors.green,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.green),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.yellow,
                    isSelected: drawingState.selectedColor == Colors.yellow,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.yellow),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.purple,
                    isSelected: drawingState.selectedColor == Colors.purple,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.purple),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.orange,
                    isSelected: drawingState.selectedColor == Colors.orange,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.orange),
                  ),
                  _buildColorButton(
                    context: context,
                    color: Colors.brown,
                    isSelected: drawingState.selectedColor == Colors.brown,
                    onTap: () => ref
                        .read(drawingProvider.notifier)
                        .updateColor(Colors.brown),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.black,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.brown,
          ]
              .map((color) => _ColorButton(
                    color: color,
                    onTap: () {
                      ref.read(drawingProvider.notifier).updateColor(color);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showBrushSettings(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.brushSize,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: drawingState.strokeWidth,
              min: 1,
              max: 20,
              divisions: 19,
              label: drawingState.strokeWidth.round().toString(),
              onChanged: (value) {
                ref.read(drawingProvider.notifier).setStrokeWidth(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton({
    required BuildContext context,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
      ),
    );
  }
}
