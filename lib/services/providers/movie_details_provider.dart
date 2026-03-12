import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/model/movie_metadata.dart';
import 'package:m3u_player/services/imdb_service.dart';
import 'package:m3u_player/services/omdb_service.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';

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
      final selectedSeries = ref.watch(selectedSeriesProvider);
      if (selectedSeries == null) return null;
      final result = await OmdbService().getMovieMetadataListFromIdOrTitle(
        id: id,
      );
      return result;
    });
