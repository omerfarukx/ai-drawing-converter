import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/drawing.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../providers/gallery_provider.dart';
import '../pages/drawing_detail_page.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final drawingsAsyncValue = ref.watch(galleryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryTab),
      ),
      body: Column(
        children: [
          // Kategori filtresi
          SizedBox(
            height: 50,
            child: ref.watch(categoriesProvider).when(
                  data: (categories) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      final category =
                          index == 0 ? 'Tümü' : categories[index - 1];
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (_) {
                            ref.read(selectedCategoryProvider.notifier).state =
                                category == 'Tümü' ? null : category;
                          },
                        ),
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Hata: $error')),
                ),
          ),
          // Çizim listesi
          Expanded(
            child: drawingsAsyncValue.when(
              data: (drawings) => drawings.isEmpty
                  ? const Center(child: Text('Henüz çizim yok'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: drawings.length,
                      itemBuilder: (context, index) {
                        final drawing = drawings[index];
                        return _DrawingCard(drawing: drawing);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Hata: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingCard extends StatelessWidget {
  final Drawing drawing;

  const _DrawingCard({required this.drawing});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DrawingDetailPage(id: drawing.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.file(
                File(drawing.path),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drawing.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        drawing.category == 'AI'
                            ? Icons.auto_awesome
                            : Icons.brush,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        drawing.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        drawing.createdAt.toString().split(' ')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
