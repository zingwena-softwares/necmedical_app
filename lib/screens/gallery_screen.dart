import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/wordpress_providers.dart';
import '../widgets/skeleton_loaders.dart';
import 'gallery_detail_screen.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(galleryImagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(galleryImagesProvider.future),
        child: images.when(
          loading: () => const GalleryGridSkeleton(),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (images) {
            if (images.isEmpty) {
              return const Center(child: Text('No images yet.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GalleryDetailScreen(images: images, initialIndex: index)),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: images[index].url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
