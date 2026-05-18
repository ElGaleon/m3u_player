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

  MovieMetadata copyWith({
    String? title,
    String? year,
    String? rated,
    String? released,
    String? runtime,
    String? genre,
    String? director,
    String? writer,
    String? actors,
    String? plot,
    String? language,
    String? country,
    String? awards,
    String? poster,
    List<Rating>? ratings,
    String? metascore,
    String? imdbRating,
    String? imdbVotes,
    String? imdbId,
    String? type,
    String? dvd,
    String? boxOffice,
    String? production,
    String? website,
    String? response,
  }) {
    return MovieMetadata(
      title: title ?? this.title,
      year: year ?? this.year,
      rated: rated ?? this.rated,
      released: released ?? this.released,
      runtime: runtime ?? this.runtime,
      genre: genre ?? this.genre,
      director: director ?? this.director,
      writer: writer ?? this.writer,
      actors: actors ?? this.actors,
      plot: plot ?? this.plot,
      language: language ?? this.language,
      country: country ?? this.country,
      awards: awards ?? this.awards,
      poster: poster ?? this.poster,
      ratings: ratings ?? this.ratings,
      metascore: metascore ?? this.metascore,
      imdbRating: imdbRating ?? this.imdbRating,
      imdbVotes: imdbVotes ?? this.imdbVotes,
      imdbId: imdbId ?? this.imdbId,
      type: type ?? this.type,
      dvd: dvd ?? this.dvd,
      boxOffice: boxOffice ?? this.boxOffice,
      production: production ?? this.production,
      website: website ?? this.website,
      response: response ?? this.response,
    );
  }

  factory MovieMetadata.fake() {
    return MovieMetadata(
      title: "Interstellar",
      year: "2014",
      rated: "PG-13",
      released: "07 Nov 2014",
      runtime: "169 min",
      genre: "Adventure, Drama, Sci-Fi",
      director: "Christopher Nolan",
      writer: "Jonathan Nolan, Christopher Nolan",
      actors: "Matthew McConaughey, Anne Hathaway, Jessica Chastain",
      plot:
          "In a future where Earth is becoming uninhabitable, a farmer and ex-NASA pilot is tasked to pilot a spacecraft, along with a team of researchers, to find a new planet for humans.",
      language: "English",
      country: "United States, United Kingdom, Canada",
      awards: "Won 1 Oscar. 44 wins & 148 nominations total",
      poster:
          "https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg",
      ratings: [
        Rating(source: "Internet Movie Database", value: "8.7/10"),
        Rating(source: "Rotten Tomatoes", value: "73%"),
        Rating(source: "Metacritic", value: "74/100"),
      ],
      metascore: "74",
      imdbRating: "8.7",
      imdbVotes: "2,042,521",
      imdbId: "tt1165520",
      type: "movie",
      dvd: "31 Mar 2015",
      boxOffice: "\$188,020,017",
      production: "N/A",
      website: "N/A",
      response: "True",
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
