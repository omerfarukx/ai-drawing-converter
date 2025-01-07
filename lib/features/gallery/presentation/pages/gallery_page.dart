import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/gallery_provider.dart';
import 'drawing_detail_page.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final drawingsAsync = ref.watch(filteredDrawingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryTab),
      ),
      body: Column(
        children: [
          // Kategori filtresi
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: categories.length + 1, // +1 for "All" option
                  itemBuilder: (context, index) {
                    final category = index == 0 ? null : categories[index - 1];
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category ?? l10n.allCategories),
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Çizim listesi
          Expanded(
            child: drawingsAsync.when(
              data: (drawings) {
                if (drawings.isEmpty) {
                  return Center(
                    child: Text(l10n.noDrawings),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: drawings.length,
                  itemBuilder: (context, index) {
                    final drawing = drawings[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrawingDetailPage(
                                drawing: drawing,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.file(
                                File(drawing.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (drawing.title != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  drawing.title!,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text(l10n.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
