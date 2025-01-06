import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/drawing_provider.dart';
import '../../domain/services/drawing_service.dart';
import 'ai_button.dart';

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPaint = ref.watch(drawingProvider).currentPaint;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Aktif renk göstergesi
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: currentPaint.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentPaint.color.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Fırça kalınlığı göstergesi
            Text(
              currentPaint.strokeWidth.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Fırça kalınlığı ayarı
            RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                width: 150,
                child: Slider(
                  value: currentPaint.strokeWidth,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    ref.read(drawingProvider.notifier).updateStrokeWidth(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Silgi aracı
            GestureDetector(
              onTap: () {
                ref.read(drawingProvider.notifier).updateColor(Colors.white);
              },
              child: Container(
                width: 35,
                height: 35,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.auto_fix_high,
                    color: Colors.grey, size: 20),
              ),
            ),
            // Renk seçimi
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: AppTheme.drawingColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    ref.read(drawingProvider.notifier).updateColor(color);
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Kaydet butonu
            Container(
              width: 45,
              height: 45,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    try {
                      final size = MediaQuery.of(context).size;
                      final drawingState = ref.read(drawingProvider);
                      if (drawingState.points.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen önce bir çizim yapın'),
                          ),
                        );
                        return;
                      }
                      final filePath = await DrawingService.saveDrawingToFile(
                        drawingState.points,
                        Size(size.width - 80, size.height),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Çizim kaydedildi: $filePath'),
                            action: SnackBarAction(
                              label: 'Göster',
                              onPressed: () async {
                                final dir =
                                    await DrawingService.getDrawingsDirectory();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Kayıt konumu: $dir'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
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
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // AI Butonu
            const AIButton(),
          ],
        ),
      ),
    );
  }
}
