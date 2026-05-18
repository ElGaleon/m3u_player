import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/episode_response.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/model/media_details.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/model/movie_metadata.dart';
import 'package:m3u_player/services/imdb_service.dart';
import 'package:m3u_player/services/omdb_service.dart';
import 'package:m3u_player/services/tmdb_service.dart';

final imdbMetadataProvider = FutureProvider.family
    .autoDispose<ImdbMetadata?, String>((ref, movieTitle) async {
      if (movieTitle.isEmpty) return null;
      final result = await ImdbService().getImdbMetadataListFromTitle(
        movieTitle,
      );
      return result.firstOrNull;
    });

final movieMetadataProvider = FutureProvider.family
    .autoDispose<MovieMetadata?, String>((ref, id) async {
      if (id.isEmpty) return null;
      final result = await OmdbService().getMovieMetadataListFromIdOrTitle(
        id: id,
      );
      return result;
    });

final mediaDetailsProvider = FutureProvider.autoDispose
    .family<MediaDetails, MediaEntity>((ref, media) async {
      final imdbMetadata = await _findBestImdbMatch(media);
      final year = _mediaYear(media);
      final metadata = await OmdbService().getMovieMetadataListFromIdOrTitle(
        id: imdbMetadata?.imdbId,
        title: imdbMetadata?.imdbId == null ? media.title : null,
        year: year,
      );
      final imdbId = metadata?.imdbId ?? imdbMetadata?.imdbId;
      final trailer = imdbId == null
          ? null
          : await TMDbService().getTrailerByImdbId(imdbId);
      return MediaDetails(
        imdb: imdbMetadata,
        metadata: metadata,
        trailer: trailer,
      );
    });

final episodeMetadataProvider = FutureProvider.autoDispose<EpisodeResponse?>((
  ref,
) async {
  return await TMDbService().getEpisodeMetadata();
});

Future<ImdbMetadata?> _findBestImdbMatch(MediaEntity media) async {
  final results = await ImdbService().getImdbMetadataListFromTitle(media.title);
  if (results.isEmpty) return null;
  final normalizedTitle = _normalize(media.title);
  final year = _mediaYear(media);
  return results.firstWhere((metadata) {
    final titleMatches = _normalize(metadata.title ?? '') == normalizedTitle;
    final yearMatches = year == null || metadata.year?.toString() == year;
    return titleMatches && yearMatches;
  }, orElse: () => results.first);
}

String? _mediaYear(MediaEntity media) {
  return switch (media) {
    Movie movie => movie.year,
    Series series => series.year,
    _ => null,
  };
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
