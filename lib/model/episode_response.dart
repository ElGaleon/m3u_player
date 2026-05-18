class EpisodeResponse {
  final String? airDate;
  final List<Crew>? crew;
  final int? episodeNumber;
  final String? episodeType;
  final List<GuestStar>? guestStars;
  final String? name;
  final String? overview;
  final int? id;
  final String? productionCode;
  final int? runtime;
  final int? seasonNumber;
  final String? stillPath;
  final double? voteAverage;
  final int? voteCount;

  EpisodeResponse({
    this.airDate,
    this.crew,
    this.episodeNumber,
    this.episodeType,
    this.guestStars,
    this.name,
    this.overview,
    this.id,
    this.productionCode,
    this.runtime,
    this.seasonNumber,
    this.stillPath,
    this.voteAverage,
    this.voteCount,
  });

  factory EpisodeResponse.fromJson(Map<String, dynamic> json) {
    return EpisodeResponse(
      airDate: json['air_date'],
      crew: json['crew'] != null
          ? List<Crew>.from(json['crew'].map((x) => Crew.fromJson(x)))
          : null,
      episodeNumber: json['episode_number'],
      episodeType: json['episode_type'],
      guestStars: json['guest_stars'] != null
          ? List<GuestStar>.from(
              json['guest_stars'].map((x) => GuestStar.fromJson(x)),
            )
          : null,
      name: json['name'],
      overview: json['overview'],
      id: json['id'],
      productionCode: json['production_code'],
      runtime: json['runtime'],
      seasonNumber: json['season_number'],
      stillPath: json['still_path'],
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'],
    );
  }
}

class Crew {
  final String? job;
  final String? department;
  final String? creditId;
  final bool? adult;
  final int? gender;
  final int? id;
  final String? knownForDepartment;
  final String? name;
  final String? originalName;
  final double? popularity;
  final String? profilePath;

  Crew({
    this.job,
    this.department,
    this.creditId,
    this.adult,
    this.gender,
    this.id,
    this.knownForDepartment,
    this.name,
    this.originalName,
    this.popularity,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      job: json['job'],
      department: json['department'],
      creditId: json['credit_id'],
      adult: json['adult'],
      gender: json['gender'],
      id: json['id'],
      knownForDepartment: json['known_for_department'],
      name: json['name'],
      originalName: json['original_name'],
      popularity: (json['popularity'] as num?)?.toDouble(),
      profilePath: json['profile_path'],
    );
  }
}

class GuestStar {
  final String? character;
  final String? creditId;
  final int? order;
  final bool? adult;
  final int? gender;
  final int? id;
  final String? knownForDepartment;
  final String? name;
  final String? originalName;
  final double? popularity;
  final String? profilePath;

  GuestStar({
    this.character,
    this.creditId,
    this.order,
    this.adult,
    this.gender,
    this.id,
    this.knownForDepartment,
    this.name,
    this.originalName,
    this.popularity,
    this.profilePath,
  });

  factory GuestStar.fromJson(Map<String, dynamic> json) {
    return GuestStar(
      character: json['character'],
      creditId: json['credit_id'],
      order: json['order'],
      adult: json['adult'],
      gender: json['gender'],
      id: json['id'],
      knownForDepartment: json['known_for_department'],
      name: json['name'],
      originalName: json['original_name'],
      popularity: (json['popularity'] as num?)?.toDouble(),
      profilePath: json['profile_path'],
    );
  }
}
