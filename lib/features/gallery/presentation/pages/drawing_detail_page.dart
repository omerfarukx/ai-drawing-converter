import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/drawing.dart';
import '../providers/gallery_provider.dart';

class DrawingDetailPage extends ConsumerWidget {
  final Drawing drawing;

  const DrawingDetailPage({
    super.key,
    required this.drawing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(drawing.title ?? l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.shareXFiles([XFile(drawing.path)]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.delete),
                  content: Text(l10n.deleteConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(galleryRepositoryProvider)
                              .deleteDrawing(drawing.id);

                          // Provider'ları yenile
                          ref.invalidate(drawingsProvider);
                          ref.invalidate(categoriesProvider);
                          ref.invalidate(filteredDrawingsProvider);

                          if (context.mounted) {
                            Navigator.pop(context); // Dialog'u kapat
                            Navigator.pop(context); // Detay sayfasını kapat
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                File(drawing.path),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (drawing.title != null) ...[
                    Text(
                      drawing.title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (drawing.description != null) ...[
                    Text(
                      drawing.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Chip(
                    label: Text(drawing.category),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createdAt(
                        drawing.createdAt.toLocal().toString().split('.')[0]),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
