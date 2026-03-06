import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/services/imdb_service.dart';

final imdbMetadataProvider = FutureProvider.family
    .autoDispose<ImdbMetadata?, String>((ref, movieTitle) async {
      if (movieTitle.isEmpty) return null;
      final result = await ImdbService().getImdbMetadataListFromTitle(
        movieTitle,
      );
      return result.firstOrNull;
    });
