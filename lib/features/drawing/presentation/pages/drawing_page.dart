import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/drawing_provider.dart';
import '../../domain/models/drawing_state.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/ai_button.dart';
import '../../../gallery/presentation/providers/gallery_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';

class DrawingPage extends ConsumerStatefulWidget {
  const DrawingPage({super.key});

  @override
  ConsumerState<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends ConsumerState<DrawingPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drawingState = ref.watch(drawingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(l10n.drawingTab),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            pinned: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(drawingProvider.notifier).clear();
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    final authState = ref.read(authControllerProvider);

                    authState.maybeMap(
                      authenticated: (state) async {
                        try {
                          final shareDrawing = ref.read(
                            shareDrawingProvider(state.user.profile),
                          );

                          if (drawingState.lines.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Önce bir çizim yapmalısınız!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          // Çizimi kaydet
                          final imageUrl = await drawingState.saveToImage();

                          // Çizimi paylaş
                          await shareDrawing(
                            imageUrl: imageUrl,
                            title:
                                "Yeni Çizim ${DateTime.now().day}/${DateTime.now().month}",
                            description: "Yapay zeka ile oluşturulmuş çizim",
                            category: "AI Çizim",
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Çizim başarıyla paylaşıldı!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hata: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      orElse: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Çizim paylaşmak için giriş yapmalısınız.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Çizim alanı
                          const DrawingCanvas(),

                          // Çizim araç çubuğu
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AiButton(),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF533483),
                                        Color(0xFF0F3460),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF533483)
                                            .withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const DrawingToolbar(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
