import 'package:flutter/material.dart';
import 'package:m3u_player/api/omdb.dart';
import 'package:m3u_player/model/movie_metadata.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OmdbService {
  static const _instance = OmdbService._();

  const OmdbService._();

  factory OmdbService() => _instance;

  Future<MovieMetadata?> getMovieMetadataListFromIdOrTitle({
    String? id,
    String? title,
  }) async {
    try {
      final result = await OmdbClient().findOmdbMetadataByIdOrTitle(
        id: id,
        title: title,
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
}
