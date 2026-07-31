import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders an attraction photo from wherever it lives.
///
/// `imageUrl` may be a bundled asset path ("assets/images/lake-kivu.jpg"), a
/// remote URL from Firestore, or empty. Bundled assets are preferred because
/// they render with no connectivity, which is the whole point of the app.
class AttractionImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const AttractionImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  bool get _isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _Placeholder();

    if (_isAsset) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (_, _, _) => _Placeholder(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      // Offline is an expected state here, not a failure worth shouting about.
      placeholder: (_, _) => _Placeholder(),
      errorWidget: (_, _, _) => _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          color: theme.colorScheme.outline,
          size: 32,
        ),
      ),
    );
  }
}
