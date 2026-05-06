import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/note_file.dart';

const _kGridHeight = 240.0;
const _kRadius = 10.0;
const _kSpacing = 4.0;
const _kRevealFadeDuration = Duration(milliseconds: 100);

ValueKey<String> _tileKeyFor(NoteFile file) => ValueKey(
  '${file.thumbnailUrl ?? ''}|${file.blurhash ?? ''}|${file.isSensitive}',
);

class NoteMediaList extends StatelessWidget {
  const NoteMediaList({required this.files, this.showAll = false, super.key});

  final List<NoteFile> files;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final imageFiles = files.where((f) => f.isImage).toList(growable: false);
    if (imageFiles.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kRadius),
      child: SizedBox(
        height: imageFiles.length == 1 ? null : _kGridHeight,
        child: showAll
            ? _all(imageFiles)
            : switch (imageFiles.length) {
                1 => _SingleImageAspectRatioTile(file: imageFiles[0]),
                2 => _two(imageFiles),
                3 => _three(imageFiles),
                _ => _four(imageFiles),
              },
      ),
    );
  }

  Widget _all(List<NoteFile> files) {
    if (files.length == 1) {
      return _SingleImageAspectRatioTile(file: files[0]);
    }

    return GridView.builder(
      itemCount: files.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: _kSpacing,
        crossAxisSpacing: _kSpacing,
      ),
      itemBuilder: (context, index) {
        final file = files[index];
        return _Tile(key: _tileKeyFor(file), file: file);
      },
    );
  }

  Widget _two(List<NoteFile> files) => Row(
    spacing: _kSpacing,
    children: [
      Expanded(
        child: _Tile(key: _tileKeyFor(files[0]), file: files[0]),
      ),
      Expanded(
        child: _Tile(key: _tileKeyFor(files[1]), file: files[1]),
      ),
    ],
  );

  Widget _three(List<NoteFile> files) => Row(
    spacing: _kSpacing,
    children: [
      Expanded(
        child: _Tile(key: _tileKeyFor(files[0]), file: files[0]),
      ),
      Expanded(
        child: Column(
          spacing: _kSpacing,
          children: [
            Expanded(
              child: _Tile(key: _tileKeyFor(files[1]), file: files[1]),
            ),
            Expanded(
              child: _Tile(key: _tileKeyFor(files[2]), file: files[2]),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _four(List<NoteFile> files) {
    final extra = files.length - 4;
    return Column(
      spacing: _kSpacing,
      children: [
        Expanded(
          child: Row(
            spacing: _kSpacing,
            children: [
              Expanded(
                child: _Tile(key: _tileKeyFor(files[0]), file: files[0]),
              ),
              Expanded(
                child: _Tile(key: _tileKeyFor(files[1]), file: files[1]),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            spacing: _kSpacing,
            children: [
              Expanded(
                child: _Tile(key: _tileKeyFor(files[2]), file: files[2]),
              ),
              Expanded(
                child: extra > 0
                    ? _OverlayTile(file: files[3], extra: extra)
                    : _Tile(key: _tileKeyFor(files[3]), file: files[3]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends HookWidget {
  const _Tile({required this.file, super.key});

  final NoteFile file;

  @override
  Widget build(BuildContext context) {
    final revealed = useState(!file.isSensitive);
    final imageWidget = _MediaImage(file: file);

    if (!file.isSensitive) {
      return SizedBox.expand(key: const ValueKey('normal'), child: imageWidget);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: !revealed.value, child: imageWidget),
        _SensitiveOverlay(
          blurhash: file.blurhash,
          revealed: revealed.value,
          onReveal: () {
            revealed.value = true;
          },
        ),
        if (revealed.value)
          Positioned(
            top: 8,
            right: 8,
            child: _HideSensitiveButton(
              onPressed: () {
                revealed.value = false;
              },
            ),
          ),
      ],
    );
  }
}

class _MediaImage extends StatelessWidget {
  const _MediaImage({required this.file});

  final NoteFile file;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = file.thumbnailUrl;
    if (thumbnailUrl == null) {
      return _BlurHashOrFallback(blurhash: file.blurhash);
    }

    return CachedNetworkImage(
      imageUrl: thumbnailUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, _) => _BlurHashOrFallback(blurhash: file.blurhash),
      errorWidget: (context, _, _) =>
          _BlurHashOrFallback(blurhash: file.blurhash),
    );
  }
}

class _SensitiveOverlay extends StatelessWidget {
  const _SensitiveOverlay({
    required this.blurhash,
    required this.revealed,
    required this.onReveal,
  });

  final String? blurhash;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: revealed,
      child: AnimatedOpacity(
        duration: revealed ? _kRevealFadeDuration : Duration.zero,
        opacity: revealed ? 0 : 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            _BlurHashOrFallback(blurhash: blurhash),
            ColoredBox(
              color: Colors.black54,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact =
                      constraints.maxHeight < 140 || constraints.maxWidth < 140;
                  final iconSize = isCompact ? 20.0 : 26.0;
                  final spacingSmall = isCompact ? 6.0 : 12.0;
                  final spacingLarge = isCompact ? 8.0 : 16.0;

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        SizedBox(height: spacingSmall),
                        Text(
                          'センシティブ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: spacingLarge),
                        OutlinedButton(
                          onPressed: onReveal,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 10 : 16,
                              vertical: isCompact ? 6 : 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('タップして表示'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HideSensitiveButton extends StatelessWidget {
  const _HideSensitiveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.visibility_off, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SingleImageAspectRatioTile extends StatelessWidget {
  const _SingleImageAspectRatioTile({required this.file});

  static const _maxLandscapeRatio = 16 / 9;
  static const _maxPortraitRatio = 9 / 16;

  final NoteFile file;

  double _aspectRatio() {
    final props = file.properties;
    if (props == null || props.width <= 0 || props.height <= 0) {
      return _maxLandscapeRatio;
    }
    return (props.width / props.height)
        .clamp(_maxPortraitRatio, _maxLandscapeRatio)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio(),
      child: _Tile(key: _tileKeyFor(file), file: file),
    );
  }
}

class _OverlayTile extends StatelessWidget {
  const _OverlayTile({required this.file, required this.extra});

  final NoteFile file;
  final int extra;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Tile(key: _tileKeyFor(file), file: file),
        ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Text(
              '+$extra',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurHashOrFallback extends StatelessWidget {
  const _BlurHashOrFallback({required this.blurhash});

  final String? blurhash;

  @override
  Widget build(BuildContext context) {
    final hash = blurhash;
    if (hash != null && hash.isNotEmpty) {
      return BlurHash(hash: hash);
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_outlined)),
    );
  }
}
