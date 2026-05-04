import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/note_file.dart';

const _kGridHeight = 240.0;
const _kRadius = 10.0;
const _kSpacing = 4.0;

class NoteMediaList extends StatelessWidget {
  const NoteMediaList({required this.files, super.key});

  final List<NoteFile> files;

  @override
  Widget build(BuildContext context) {
    final imageFiles = files.where((f) => f.isImage).toList(growable: false);
    if (imageFiles.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kRadius),
      child: SizedBox(
        height: imageFiles.length == 1 ? null : _kGridHeight,
        child: switch (imageFiles.length) {
          1 => _SingleImageAspectRatioTile(file: imageFiles[0]),
          2 => _two(imageFiles),
          3 => _three(imageFiles),
          _ => _four(imageFiles),
        },
      ),
    );
  }

  Widget _two(List<NoteFile> files) => Row(
    spacing: _kSpacing,
    children: [
      Expanded(child: _Tile(file: files[0])),
      Expanded(child: _Tile(file: files[1])),
    ],
  );

  Widget _three(List<NoteFile> files) => Row(
    spacing: _kSpacing,
    children: [
      Expanded(child: _Tile(file: files[0])),
      Expanded(
        child: Column(
          spacing: _kSpacing,
          children: [
            Expanded(child: _Tile(file: files[1])),
            Expanded(child: _Tile(file: files[2])),
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
              Expanded(child: _Tile(file: files[0])),
              Expanded(child: _Tile(file: files[1])),
            ],
          ),
        ),
        Expanded(
          child: Row(
            spacing: _kSpacing,
            children: [
              Expanded(child: _Tile(file: files[2])),
              Expanded(
                child: extra > 0
                    ? _OverlayTile(file: files[3], extra: extra)
                    : _Tile(file: files[3]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends HookWidget {
  const _Tile({required this.file});

  final NoteFile file;

  @override
  Widget build(BuildContext context) {
    final revealed = useState(!file.isSensitive);
    return _buildContent(context, revealed);
  }

  Widget _buildContent(BuildContext context, ValueNotifier<bool> revealed) {
    final thumbnailUrl = file.thumbnailUrl;
    final imageWidget = thumbnailUrl == null
        ? _BlurHashOrFallback(blurhash: file.blurhash)
        : CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, _) =>
                _BlurHashOrFallback(blurhash: file.blurhash),
            errorWidget: (context, _, _) =>
                _BlurHashOrFallback(blurhash: file.blurhash),
          );

    if (!file.isSensitive) {
      return SizedBox.expand(key: const ValueKey('normal'), child: imageWidget);
    }

    // センシティブ画像は実画像を背面で先読みし、前面のblurhash+レイヤーで完全に隠す
    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        IgnorePointer(
          ignoring: revealed.value,
          child: AnimatedOpacity(
            duration: revealed.value
                ? const Duration(milliseconds: 100)
                : Duration.zero,
            opacity: revealed.value ? 0 : 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _BlurHashOrFallback(blurhash: file.blurhash),
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'センシティブ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            revealed.value = true;
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('タップして表示'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 表示状態の場合のみ隠すボタンを表示
        if (revealed.value)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                revealed.value = false;
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
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
      child: _Tile(file: file),
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
        _Tile(file: file),
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
