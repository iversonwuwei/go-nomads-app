import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NomadHeroImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double height;
  final Widget? bottomOverlay;

  const NomadHeroImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height = 300,
    this.bottomOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            placeholder: (context, url) => Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).cardColor,
              child: const Center(
                child: Icon(Icons.error),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          if (bottomOverlay != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: bottomOverlay!,
            ),
        ],
      ),
    ),
  );
}
}
