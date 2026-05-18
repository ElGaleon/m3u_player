import 'package:m3u_player/api/base.dart';
import 'package:m3u_player/model/episode_response.dart';
import 'package:m3u_player/model/media_details.dart';

class TMDbClient {
  static const _instance = TMDbClient._();

  const TMDbClient._();

  factory TMDbClient() => _instance;

  static const _baseUrl = 'https://api.themoviedb.org';
  static const version = 3;

  Future<EpisodeResponse> getEpisodeMetadata({
    String seriesId = '61068',
    int season = 1,
    int episode = 2,
  }) async {
    final url =
        '$_baseUrl/$version/tv/$seriesId/season/$season/episode/$episode';
    final params = {'language': 'it-IT'};
    final response = await BaseClient().get(
      url,
      params: params,
      tmdbClient: true,
    );
    return EpisodeResponse.fromJson(response.data as Json);
  }

  Future<TMDbTitleMatch?> findTitleByImdbId(String imdbId) async {
    final url = '$_baseUrl/$version/find/$imdbId';
    final params = {'external_source': 'imdb_id', 'language': 'it-IT'};
    final response = await BaseClient().get(
      url,
      params: params,
      tmdbClient: true,
    );
    final data = response.data as Json;
    final movieResults = data['movie_results'] as List<dynamic>? ?? [];
    if (movieResults.isNotEmpty) {
      final first = movieResults.first as Json;
      return TMDbTitleMatch(id: first['id'] as int, mediaType: 'movie');
    }
    final tvResults = data['tv_results'] as List<dynamic>? ?? [];
    if (tvResults.isNotEmpty) {
      final first = tvResults.first as Json;
      return TMDbTitleMatch(id: first['id'] as int, mediaType: 'tv');
    }
    return null;
  }

  Future<MediaTrailer?> getTrailer({
    required int id,
    required String mediaType,
  }) async {
    final localizedTrailer = await _getTrailer(
      id: id,
      mediaType: mediaType,
      language: 'it-IT',
    );
    if (localizedTrailer != null) return localizedTrailer;
    return _getTrailer(id: id, mediaType: mediaType, language: 'en-US');
  }

  Future<MediaTrailer?> _getTrailer({
    required int id,
    required String mediaType,
    required String language,
  }) async {
    final url = '$_baseUrl/$version/$mediaType/$id/videos';
    final response = await BaseClient().get(
      url,
      params: {'language': language},
      tmdbClient: true,
    );
    final data = response.data as Json;
    final results = data['results'] as List<dynamic>? ?? [];
    final trailers = results
        .map((item) => item as Json)
        .where((item) => item['type'] == 'Trailer')
        .toList();
    final selected = trailers.firstWhere(
      (item) => item['official'] == true && item['site'] == 'YouTube',
      orElse: () => trailers.firstOrNull ?? <String, dynamic>{},
    );
    final key = selected['key'] as String?;
    final site = selected['site'] as String?;
    final name = selected['name'] as String?;
    if (key == null || site == null || name == null) return null;
    final trailerUrl = site.toLowerCase() == 'youtube'
        ? 'https://www.youtube.com/watch?v=$key'
        : key;
    return MediaTrailer(name: name, site: site, key: key, url: trailerUrl);
  }
}

class TMDbTitleMatch {
  final int id;
  final String mediaType;

  const TMDbTitleMatch({required this.id, required this.mediaType});
}
