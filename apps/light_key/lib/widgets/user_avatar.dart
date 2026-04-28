import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.avatarUrl,
    this.avatarBlurHash,
    this.size = 40,
    super.key,
  });

  final String? avatarUrl;
  final String? avatarBlurHash;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person_outline, size: size * 0.5),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) {
          final blurHash = avatarBlurHash;
          if (blurHash != null && blurHash.isNotEmpty) {
            return BlurHash(hash: blurHash);
          }
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorWidget: (context, _, __) => CircleAvatar(
          radius: size / 2,
          child: Icon(Icons.person_outline, size: size * 0.5),
        ),
      ),
    );
  }
}
