import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Renders `imageUrl` as a bundled asset, a remote URL, or a placeholder.
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.landscape_outlined, color: Colors.white70, size: 32),
      ),
    );
  }
}
