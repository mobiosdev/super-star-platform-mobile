import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Thumbnail for feed cards — supports network URLs and bundled assets.
class FeedThumbnail extends StatelessWidget {
  const FeedThumbnail({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  static bool isAssetPath(String url) => url.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (isAssetPath(url)) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => const _BrokenImage(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => const _BrokenImage(),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}
