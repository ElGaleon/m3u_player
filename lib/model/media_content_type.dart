import 'package:flutter_riverpod/legacy.dart';

enum MediaContentType { live, movie, series, unknown }

MediaContentType identifyContentType(String url) {
  if (url.contains('/movie/')) return MediaContentType.movie;
  if (url.contains('/series/')) return MediaContentType.series;
  if (url.contains(':80/') || url.endsWith('.ts') || url.endsWith('.m3u8')) {
    return MediaContentType.live;
  }
  return MediaContentType.unknown;
}

class SelectedMediaTypeNotifier extends StateNotifier<MediaContentType?> {
  SelectedMediaTypeNotifier(super.state);

  Future<void> update(MediaContentType type) async {
    state = type;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedMediaTypeProvider =
    StateNotifierProvider<SelectedMediaTypeNotifier, MediaContentType?>(
      (ref) => SelectedMediaTypeNotifier(null),
    );
