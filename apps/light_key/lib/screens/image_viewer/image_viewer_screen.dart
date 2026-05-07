import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note_file.dart';
import '../../utils/image_hero_tag.dart';
import 'image_viewer_provider.dart';

class ImageViewerScreen extends HookWidget {
  const ImageViewerScreen({
    required this.files,
    required this.initialIndex,
    super.key,
  });

  final List<NoteFile> files;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageViewerProvider(
        files: files,
        initialIndex: initialIndex,
      ),
      child: const _ImageViewerContent(),
    );
  }
}

class _ImageViewerContent extends HookWidget {
  const _ImageViewerContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ImageViewerProvider>();
    final pageController = usePageController(initialPage: provider.currentIndex);

    useEffect(() {
      pageController.addListener(() {
        final page = pageController.page?.round() ?? provider.currentIndex;
        if (page != provider.currentIndex) {
          provider.goToImage(page);
        }
      });
      return null;
    }, [pageController, provider]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(
          '${provider.currentIndex + 1}/${provider.files.length}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const ColoredBox(color: Colors.black54),
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              provider.goToImage(index);
            },
            itemCount: provider.files.length,
            itemBuilder: (context, index) {
              final file = provider.files[index];
              return _ImageViewerPage(file: file, index: index);
            },
          ),
          // ビューカウンター下部
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${provider.currentIndex + 1}/${provider.files.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({required this.file, required this.index});

  final NoteFile file;
  final int index;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = file.thumbnailUrl;

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white54,
          size: 48,
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Hero(
          tag: buildImageHeroTag(file: file, index: index),
          createRectTween: (begin, end) => RectTween(begin: begin, end: end),
          child: CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
