import '../api/base.dart';

class MovieMetadata {
  final String? title;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? awards;
  final String? poster;
  final List<Rating>? ratings;
  final String? metascore;
  final String? imdbRating;
  final String? imdbVotes;
  final String? imdbId;
  final String? type;
  final String? dvd;
  final String? boxOffice;
  final String? production;
  final String? website;
  final String? response;

  MovieMetadata({
    this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.poster,
    this.ratings,
    this.metascore,
    this.imdbRating,
    this.imdbVotes,
    this.imdbId,
    this.type,
    this.dvd,
    this.boxOffice,
    this.production,
    this.website,
    this.response,
  });

  factory MovieMetadata.fromJson(Json json) {
    return MovieMetadata(
      title: json['Title'],
      year: json['Year'],
      rated: json['Rated'],
      released: json['Released'],
      runtime: json['Runtime'],
      genre: json['Genre'],
      director: json['Director'],
      writer: json['Writer'],
      actors: json['Actors'],
      plot: json['Plot'],
      language: json['Language'],
      country: json['Country'],
      awards: json['Awards'],
      poster: json['Poster'],
      ratings: json['Ratings'] != null
          ? (json['Ratings'] as List).map((i) => Rating.fromJson(i)).toList()
          : null,
      metascore: json['Metascore'],
      imdbRating: json['imdbRating'],
      imdbVotes: json['imdbVotes'],
      imdbId: json['imdbID'],
      type: json['Type'],
      dvd: json['DVD'],
      boxOffice: json['BoxOffice'],
      production: json['Production'],
      website: json['Website'],
      response: json['Response'],
    );
  }

  // Comodo per la funzione di traduzione di cui parlavamo prima
  MovieMetadata copyWith({String? plot}) {
    return MovieMetadata(
      title: title,
      year: year,
      rated: rated,
      released: released,
      runtime: runtime,
      genre: genre,
      director: director,
      writer: writer,
      actors: actors,
      plot: plot ?? this.plot, // Aggiorna solo il plot se fornito
      language: language,
      country: country,
      awards: awards,
      poster: poster,
      ratings: ratings,
      metascore: metascore,
      imdbRating: imdbRating,
      imdbVotes: imdbVotes,
      imdbId: imdbId,
      type: type,
      dvd: dvd,
      boxOffice: boxOffice,
      production: production,
      website: website,
      response: response,
    );
  }
}

class Rating {
  final String? source;
  final String? value;

  Rating({this.source, this.value});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(source: json['Source'], value: json['Value']);
  }
}
