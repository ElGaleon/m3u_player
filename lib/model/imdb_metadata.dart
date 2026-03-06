class ImdbMetadata {
  final String? title;
  final String? poster;
  final String? imdbId;
  final int? year;

  ImdbMetadata({this.title, this.poster, this.imdbId, this.year});

  factory ImdbMetadata.fromJson(Map<String, dynamic> json) {
    final desc = (json['description'] as List).first;
    return ImdbMetadata(
      title: desc['#TITLE'],
      poster: desc['#IMG_POSTER'],
      imdbId: desc['#IMDB_ID'],
      year: desc['#YEAR'],
    );
  }
}
