import 'package:flutter/material.dart';
import 'package:m3u_player/api/tmdb.dart';
import 'package:m3u_player/model/episode_response.dart';
import 'package:m3u_player/model/media_details.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TMDbService {
  static const _instance = TMDbService._();

  const TMDbService._();

  factory TMDbService() => _instance;

  Future<EpisodeResponse?> getEpisodeMetadata({
    String? id,
    int? season,
    int? episode,
  }) async {
    try {
      final result = await TMDbClient().getEpisodeMetadata(
        seriesId: '61068',
        season: 1,
        episode: 2,
      );
      return result;
    } catch (err) {
      ShadToast.destructive(
        title: Text('Error'),
        description: Text(err.toString()),
      );
      return null;
    }
  }

  Future<MediaTrailer?> getTrailerByImdbId(String imdbId) async {
    try {
      final match = await TMDbClient().findTitleByImdbId(imdbId);
      if (match == null) return null;
      return await TMDbClient().getTrailer(
        id: match.id,
        mediaType: match.mediaType,
      );
    } catch (err) {
      ShadToast.destructive(
        title: Text('Error'),
        description: Text(err.toString()),
      );
      return null;
    }
  }
}
