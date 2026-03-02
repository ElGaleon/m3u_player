import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../model/series.dart';

class SeriesCard extends StatelessWidget {
  final Series series;

  const SeriesCard({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: EdgeInsetsGeometry.zero,
      backgroundColor: Colors.transparent,
      border: ShadBorder.all(
        color: Colors.transparent,
        radius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: CachedNetworkImage(
              imageUrl: series.logo,
              fit: BoxFit.cover,
              memCacheWidth: 300,
              placeholder: (context, url) => SizedBox(
                width: 24,
                height: 24,
                child: Center(child: const ShadProgress()),
              ),
              fadeInDuration: const Duration(milliseconds: 500),
              errorWidget: (context, url, error) =>
                  Center(child: const Icon(Icons.tv, size: 96)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 10),
                  ],
                  stops: const [0.5, 0.7, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 8,
            right: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  series.cleanTitle,
                  style: ShadTheme.of(context).textTheme.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (series.year != null)
                  Text(
                    series.year!,
                    style: ShadTheme.of(context).textTheme.small.copyWith(
                      color: Colors.amberAccent,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
