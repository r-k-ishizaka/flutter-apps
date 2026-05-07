import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note_file.dart';
import '../../utils/image_hero_tag.dart';
import 'image_viewer_provider.dart';

const _kDismissDragDistance = 120.0;
const _kDismissVelocity = 900.0;
const _kDragFollowMax = 240.0;

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
      create: (_) =>
          ImageViewerProvider(files: files, initialIndex: initialIndex),
      child: const _ImageViewerContent(),
    );
  }
}

class _ImageViewerContent extends HookWidget {
  const _ImageViewerContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ImageViewerProvider>();
    final pageController = usePageController(
      initialPage: provider.currentIndex,
    );
    final verticalDragDistance = useState(0.0);
    final activePointerCount = useState(0);
    final isImageInteracting = useState(false);
    final currentImageScale = useState(1.0);

    final dragOffset = (verticalDragDistance.value / 400).clamp(0.0, 0.2);
    final isZoomed = currentImageScale.value > 1.01;
    final canSwipeDismiss = activePointerCount.value <= 1 && !isZoomed;
    final canPageSwipe =
        activePointerCount.value <= 1 && !isImageInteracting.value && !isZoomed;

    void updateDismissDrag(double delta) {
      final next = (verticalDragDistance.value + delta).clamp(
        0.0,
        _kDragFollowMax,
      );
      verticalDragDistance.value = next.toDouble();
    }

    void cancelDismissDrag() {
      if (verticalDragDistance.value == 0) return;
      verticalDragDistance.value = 0;
    }

    void completeDismissDrag(double velocity) {
      final shouldDismiss =
          verticalDragDistance.value > _kDismissDragDistance ||
          velocity > _kDismissVelocity;
      verticalDragDistance.value = 0;
      if (shouldDismiss) {
        Navigator.of(context).maybePop();
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                tooltip: '閉じる',
              ),
            ),
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Listener(
        onPointerDown: (_) {
          activePointerCount.value += 1;
          if (activePointerCount.value > 1) {
            cancelDismissDrag();
          }
        },
        onPointerUp: (_) {
          activePointerCount.value = activePointerCount.value > 0
              ? activePointerCount.value - 1
              : 0;
        },
        onPointerCancel: (_) {
          activePointerCount.value = activePointerCount.value > 0
              ? activePointerCount.value - 1
              : 0;
          cancelDismissDrag();
        },
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          offset: Offset(0, dragOffset),
          child: Stack(
            children: [
              const ColoredBox(color: Colors.black54),
              PageView.builder(
                controller: pageController,
                physics: canPageSwipe
                    ? const PageScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  isImageInteracting.value = false;
                  currentImageScale.value = 1.0;
                  cancelDismissDrag();
                  provider.goToImage(index);
                },
                itemCount: provider.files.length,
                itemBuilder: (context, index) {
                  final file = provider.files[index];
                  return _ImageViewerPage(
                    file: file,
                    index: index,
                    backgroundTapEnabled:
                        !isImageInteracting.value && !isZoomed,
                    dismissDragEnabled: canSwipeDismiss,
                    onInteractionChanged: (isInteracting) {
                      isImageInteracting.value = isInteracting;
                    },
                    onScaleChanged: (scale) {
                      currentImageScale.value = scale;
                      if (scale > 1.01) {
                        cancelDismissDrag();
                      }
                    },
                    onDismissDragUpdate: updateDismissDrag,
                    onDismissDragCancel: cancelDismissDrag,
                    onDismissDragEnd: completeDismissDrag,
                  );
                },
              ),
              // ビューカウンター下部
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 16),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
        ),
      ),
    );
  }
}

class _ImageViewerPage extends HookWidget {
  const _ImageViewerPage({
    required this.file,
    required this.index,
    required this.backgroundTapEnabled,
    required this.dismissDragEnabled,
    required this.onInteractionChanged,
    required this.onScaleChanged,
    required this.onDismissDragUpdate,
    required this.onDismissDragCancel,
    required this.onDismissDragEnd,
  });

  final NoteFile file;
  final int index;
  final bool backgroundTapEnabled;
  final bool dismissDragEnabled;
  final ValueChanged<bool> onInteractionChanged;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onDismissDragUpdate;
  final VoidCallback onDismissDragCancel;
  final ValueChanged<double> onDismissDragEnd;

  @override
  Widget build(BuildContext context) {
    final fullUrl = file.url;
    final thumbnailUrl = file.thumbnailUrl;
    final transformationController = useMemoized(TransformationController.new);
    final isDismissGestureActive = useRef(false);

    useEffect(() {
      return transformationController.dispose;
    }, [transformationController]);

    if (fullUrl.isEmpty && (thumbnailUrl == null || thumbnailUrl.isEmpty)) {
      return const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
      );
    }

    // 表示するURL: フル解像度があればそれを使い、なければサムネイル
    final displayUrl = fullUrl.isNotEmpty ? fullUrl : thumbnailUrl!;

    void updateScale() {
      onScaleChanged(transformationController.value.getMaxScaleOnAxis());
    }

    bool canTrackDismiss(ScaleUpdateDetails details) {
      final scale = transformationController.value.getMaxScaleOnAxis();
      if (!dismissDragEnabled || details.pointerCount != 1 || scale > 1.01) {
        return false;
      }

      final delta = details.focalPointDelta;
      return isDismissGestureActive.value ||
          (delta.dy > 0 && delta.dy.abs() >= delta.dx.abs());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageRect = _imageRectFor(file, constraints.biggest);

        return Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              transformationController: transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionStart: (_) {
                isDismissGestureActive.value = false;
                onInteractionChanged(true);
                updateScale();
              },
              onInteractionUpdate: (details) {
                updateScale();
                if (canTrackDismiss(details)) {
                  isDismissGestureActive.value = true;
                  onDismissDragUpdate(details.focalPointDelta.dy);
                } else if (isDismissGestureActive.value) {
                  isDismissGestureActive.value = false;
                  onDismissDragCancel();
                }
              },
              onInteractionEnd: (details) {
                updateScale();
                if (isDismissGestureActive.value) {
                  isDismissGestureActive.value = false;
                  onDismissDragEnd(details.velocity.pixelsPerSecond.dy);
                } else {
                  onDismissDragCancel();
                }
                onInteractionChanged(false);
              },
              child: Hero(
                tag: buildImageHeroTag(file: file, index: index),
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: CachedNetworkImage(
                  imageUrl: displayUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) {
                    // フル解像度の読み込み中はサムネイルを表示
                    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
                      return CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white54,
                        ),
                      ),
                    );
                  },
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
            if (backgroundTapEnabled) ...[
              _DismissInteractionZone(
                top: 0,
                left: 0,
                right: 0,
                bottom: constraints.maxHeight - imageRect.top,
                dismissDragEnabled: dismissDragEnabled,
                onDismissDragUpdate: onDismissDragUpdate,
                onDismissDragCancel: onDismissDragCancel,
                onDismissDragEnd: onDismissDragEnd,
              ),
              _DismissInteractionZone(
                top: imageRect.top,
                left: 0,
                right: constraints.maxWidth - imageRect.left,
                bottom: constraints.maxHeight - imageRect.bottom,
                dismissDragEnabled: dismissDragEnabled,
                onDismissDragUpdate: onDismissDragUpdate,
                onDismissDragCancel: onDismissDragCancel,
                onDismissDragEnd: onDismissDragEnd,
              ),
              _DismissInteractionZone(
                top: imageRect.top,
                left: imageRect.right,
                right: 0,
                bottom: constraints.maxHeight - imageRect.bottom,
                dismissDragEnabled: dismissDragEnabled,
                onDismissDragUpdate: onDismissDragUpdate,
                onDismissDragCancel: onDismissDragCancel,
                onDismissDragEnd: onDismissDragEnd,
              ),
              _DismissInteractionZone(
                top: imageRect.bottom,
                left: 0,
                right: 0,
                bottom: 0,
                dismissDragEnabled: dismissDragEnabled,
                onDismissDragUpdate: onDismissDragUpdate,
                onDismissDragCancel: onDismissDragCancel,
                onDismissDragEnd: onDismissDragEnd,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DismissInteractionZone extends StatelessWidget {
  const _DismissInteractionZone({
    required this.top,
    required this.left,
    required this.right,
    required this.bottom,
    required this.dismissDragEnabled,
    required this.onDismissDragUpdate,
    required this.onDismissDragCancel,
    required this.onDismissDragEnd,
  });

  final double top;
  final double left;
  final double right;
  final double bottom;
  final bool dismissDragEnabled;
  final ValueChanged<double> onDismissDragUpdate;
  final VoidCallback onDismissDragCancel;
  final ValueChanged<double> onDismissDragEnd;

  @override
  Widget build(BuildContext context) {
    if (top.isNaN || left.isNaN || right.isNaN || bottom.isNaN) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: dismissDragEnabled
            ? (details) {
                final delta = details.primaryDelta;
                if (delta == null) return;
                onDismissDragUpdate(delta);
              }
            : null,
        onVerticalDragEnd: dismissDragEnabled
            ? (details) {
                onDismissDragEnd(details.primaryVelocity ?? 0);
              }
            : null,
        onVerticalDragCancel: onDismissDragCancel,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

Rect _imageRectFor(NoteFile file, Size viewportSize) {
  final width = viewportSize.width;
  final height = viewportSize.height;
  final properties = file.properties;

  if (width <= 0 || height <= 0) {
    return Rect.zero;
  }

  if (properties == null || properties.width <= 0 || properties.height <= 0) {
    return Rect.fromLTWH(0, 0, width, height);
  }

  final aspectRatio = properties.width / properties.height;
  final viewportRatio = width / height;

  final displayWidth =
      (viewportRatio > aspectRatio ? height * aspectRatio : width).toDouble();
  final displayHeight =
      (viewportRatio > aspectRatio ? height : width / aspectRatio).toDouble();
  final left = math.max(0.0, (width - displayWidth) / 2).toDouble();
  final top = math.max(0.0, (height - displayHeight) / 2).toDouble();

  return Rect.fromLTWH(left, top, displayWidth, displayHeight);
}
