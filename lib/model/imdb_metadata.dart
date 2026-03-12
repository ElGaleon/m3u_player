import 'package:m3u_player/api/base.dart';

class ImdbMetadata {
  final String? title;
  final String? poster;
  final String? imdbId;
  final int? year;

  ImdbMetadata({this.title, this.poster, this.imdbId, this.year});

  factory ImdbMetadata.fromJson(Json json) {
    return ImdbMetadata(
      title: json['#TITLE'],
      poster: json['#IMG_POSTER'],
      imdbId: json['#IMDB_ID'],
      year: json['#YEAR'],
    );
  }
}
