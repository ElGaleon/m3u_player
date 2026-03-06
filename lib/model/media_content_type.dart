import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum MediaContentType {
  live(
    label: 'Live Channels',
    color: AppColors.electricBlue,
    icon: Icons.live_tv_outlined,
  ),
  movie(
    label: 'Movies',
    color: AppColors.warmOrange,
    icon: Icons.movie_creation_outlined,
  ),
  series(
    label: 'Series',
    color: AppColors.denseGreen,
    icon: Icons.local_movies_outlined,
  ),
  unknown(
    label: 'Unknown',
    color: Colors.white70,
    icon: Icons.question_mark_outlined,
  );

  final String label;
  final Color color;
  final IconData icon;

  const MediaContentType({
    required this.color,
    required this.icon,
    required this.label,
  });

  factory MediaContentType.classify(String url) {
    if (url.contains('/movie/')) return MediaContentType.movie;
    if (url.contains('/series/')) return MediaContentType.series;
    if (url.contains(':80/') || url.endsWith('.ts') || url.endsWith('.m3u8')) {
      return MediaContentType.live;
    }
    return MediaContentType.unknown;
  }
}
