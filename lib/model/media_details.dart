import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/model/movie_metadata.dart';

class MediaDetails {
  final ImdbMetadata? imdb;
  final MovieMetadata? metadata;
  final MediaTrailer? trailer;

  const MediaDetails({this.imdb, this.metadata, this.trailer});
}

class MediaTrailer {
  final String name;
  final String site;
  final String key;
  final String url;

  const MediaTrailer({
    required this.name,
    required this.site,
    required this.key,
    required this.url,
  });

  bool get isYouTube => site.toLowerCase() == 'youtube';
}
