import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String? urlPoster;
  final void Function()? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.urlPoster,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ShadCard(
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
                imageUrl: urlPoster ?? movie.logo,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                placeholder: (context, url) => SizedBox.expand(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.secondary,
                    ),
                  ),
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
                    movie.title,
                    style: ShadTheme.of(context).textTheme.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.year != null)
                    Text(
                      movie.year!,
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
      ),
    );
  }
}
