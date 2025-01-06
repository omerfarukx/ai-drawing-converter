import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/drawing_provider.dart';
import '../../domain/services/drawing_service.dart';

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingState = ref.watch(drawingProvider);
    final screenWidth = MediaQuery.of(context).size.width;

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
          // Üst sıra - Araçlar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Silgi aracı
              _buildToolButton(
                context: context,
                icon: Icons.brush,
                label: 'Fırça',
                isSelected: !drawingState.isErasing,
                onTap: () {
                  if (drawingState.isErasing) {
                    ref.read(drawingProvider.notifier).toggleEraser();
                  }
                },
              ),
              _buildToolButton(
                context: context,
                icon: Icons.cleaning_services,
                label: 'Silgi',
                isSelected: drawingState.isErasing,
                onTap: () {
                  if (!drawingState.isErasing) {
                    ref.read(drawingProvider.notifier).toggleEraser();
                  }
                },
              ),
              _buildToolButton(
                context: context,
                icon: Icons.delete_outline,
                label: 'Temizle',
                onTap: () => ref.read(drawingProvider.notifier).clear(),
              ),
              _buildToolButton(
                context: context,
                icon: Icons.save,
                label: 'Kaydet',
                onTap: () => _handleSave(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Kalınlık Ayarı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    drawingState.strokeWidth.toStringAsFixed(1),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    thumbColor: Theme.of(context).primaryColor,
                    overlayColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: drawingState.strokeWidth,
                    min: 1,
                    max: 20,
                    onChanged: (value) => ref
                        .read(drawingProvider.notifier)
                        .updateStrokeWidth(value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Fırça Tipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBrushTypeButton(
                  context: context,
                  icon: Icons.brush,
                  label: 'Normal',
                  isSelected: drawingState.brushType == BrushType.normal,
                  onTap: () => ref
                      .read(drawingProvider.notifier)
                      .updateBrushType(BrushType.normal),
                ),
                const SizedBox(width: 8),
                _buildBrushTypeButton(
                  context: context,
                  icon: Icons.format_paint,
                  label: 'Yumuşak',
                  isSelected: drawingState.brushType == BrushType.soft,
                  onTap: () => ref
                      .read(drawingProvider.notifier)
                      .updateBrushType(BrushType.soft),
                ),
                const SizedBox(width: 8),
                _buildBrushTypeButton(
                  context: context,
                  icon: Icons.crop_square,
                  label: 'Kare',
                  isSelected: drawingState.brushType == BrushType.square,
                  onTap: () => ref
                      .read(drawingProvider.notifier)
                      .updateBrushType(BrushType.square),
                ),
                const SizedBox(width: 8),
                _buildBrushTypeButton(
                  context: context,
                  icon: Icons.create,
                  label: 'Kaligrafi',
                  isSelected: drawingState.brushType == BrushType.calligraphy,
                  onTap: () => ref
                      .read(drawingProvider.notifier)
                      .updateBrushType(BrushType.calligraphy),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color:
                  isSelected ? Colors.white : Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrushTypeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).iconTheme.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final drawingState = ref.read(drawingProvider);
    if (drawingState.points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir çizim yapın')),
      );
      return;
    }

    try {
      final size = MediaQuery.of(context).size;
      final filePath = await DrawingService.saveDrawingToFile(
        drawingState.points,
        Size(size.width, size.height),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çizim kaydedildi: $filePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
