sealed class MediaEntity {
  final String id;
  final String title;
  final String logo;
  final String group;

  const MediaEntity({
    required this.id,
    required this.title,
    required this.logo,
    required this.group,
  });
}

abstract class PlayableEntity extends MediaEntity {
  final List<PlayableEntityVariant> variants;

  const PlayableEntity({
    required super.id,
    required super.title,
    required super.logo,
    required super.group,
    required this.variants,
  });

  Set<String> get resolutions =>
      variants.map((variant) => variant.resolution).toSet();
}

class LiveChannel extends PlayableEntity {
  const LiveChannel({
    required super.id,
    required super.title,
    required super.logo,
    required super.group,
    required super.variants,
  });

  bool get isFake => id == 'fake';

  LiveChannel copyWith({
    String? id,
    String? title,
    String? logo,
    Uri? url,
    String? group,
    String? year,
    String? resolution,
    List<PlayableEntityVariant>? variants,
  }) => LiveChannel(
    id: id ?? this.id,
    title: title ?? this.title,
    logo: logo ?? this.logo,
    group: group ?? this.group,
    variants: variants ?? this.variants,
  );

  factory LiveChannel.fake() => LiveChannel(
    id: 'fake',
    title: 'Live Channel TV HD',
    logo: 'logo',
    group: 'Live Channel',
    variants: [
      PlayableEntityVariant(
        resolution: '4K',
        url: Uri.parse('https://example.com'),
      ),
      PlayableEntityVariant(
        resolution: 'HD',
        url: Uri.parse('https://example.com'),
      ),
    ],
  );
}

class Movie extends PlayableEntity {
  final String? year;

  const Movie({
    required super.id,
    required super.title,
    required super.logo,
    required super.group,
    required super.variants,
    this.year,
  });

  bool get isFake => id == 'fake';

  Movie copyWith({
    String? id,
    String? title,
    String? logo,
    Uri? url,
    String? group,
    String? year,
    String? resolution,
    List<PlayableEntityVariant>? variants,
  }) => Movie(
    id: id ?? this.id,
    title: title ?? this.title,
    logo: logo ?? this.logo,
    group: group ?? this.group,
    year: year ?? this.year,
    variants: variants ?? this.variants,
  );

  factory Movie.fake() => Movie(
    id: 'fake',
    title: 'Movie Title Placeholder',
    logo: 'logo',
    group: 'Adventure',
    year: '2026',
    variants: [
      PlayableEntityVariant(
        resolution: '4K',
        url: Uri.parse('https://example.com'),
      ),
      PlayableEntityVariant(
        resolution: 'HD',
        url: Uri.parse('https://example.com'),
      ),
    ],
  );
}

class Episode extends PlayableEntity {
  final int seasonNumber;
  final int episodeNumber;

  const Episode({
    required super.id,
    required super.title,
    required super.logo,
    required super.group,
    required this.seasonNumber,
    required this.episodeNumber,
    required super.variants,
  });

  bool get isFake => id == 'fake';

  Episode copyWith({
    String? id,
    String? title,
    String? logo,
    Uri? url,
    String? group,
    String? year,
    String? resolution,
    List<PlayableEntityVariant>? variants,
    int? seasonNumber,
    int? episodeNumber,
  }) => Episode(
    id: id ?? this.id,
    title: title ?? this.title,
    logo: logo ?? this.logo,
    group: group ?? this.group,
    variants: variants ?? this.variants,
    seasonNumber: seasonNumber ?? this.seasonNumber,
    episodeNumber: episodeNumber ?? this.episodeNumber,
  );

  factory Episode.fake() => Episode(
    id: 'fake',
    title: 'Episode one',
    logo: '',
    group: 'Tv Series',
    seasonNumber: 1,
    episodeNumber: 1,
    variants: [
      PlayableEntityVariant(
        resolution: '4K',
        url: Uri.parse('https://example.com'),
      ),
      PlayableEntityVariant(
        resolution: 'HD',
        url: Uri.parse('https://example.com'),
      ),
    ],
  );
}

class Series extends MediaEntity {
  final Map<int, List<Episode>> seasons;
  final String? year;

  const Series({
    required super.id,
    required super.title,
    required super.logo,
    required super.group,
    required this.seasons,
    this.year,
  });

  bool get isFake => id == 'fake';

  Set<String> get resolutions => seasons.values
      .expand((season) => season)
      .expand((episode) => episode.resolutions)
      .toSet();

  factory Series.fake() => Series(
    id: 'fake',
    title: 'Tv Series Name',
    logo: '',
    group: 'Adventure',
    year: '2023-2024',
    seasons: {1: List.generate(5, (index) => Episode.fake())},
  );

  Episode? getEpisodeBySeasonAndEpisode({
    required int seasonNumber,
    required int episodeNumber,
  }) {
    if (!seasons.containsKey(seasonNumber)) return null;

    final season = seasons[seasonNumber];
    return season
        ?.where((episode) => (episode.seasonNumber == episodeNumber))
        .firstOrNull;
  }

  Series copyWith({
    String? id,
    String? title,
    String? logo,
    Uri? url,
    String? group,
    String? year,
    String? resolution,
    Map<int, List<Episode>>? seasons,
  }) => Series(
    id: id ?? this.id,
    title: title ?? this.title,
    logo: logo ?? this.logo,
    group: group ?? this.group,
    year: year ?? this.year,
    seasons: seasons ?? this.seasons,
  );
}

class PlayableEntityVariant {
  final String resolution;
  final Uri url;

  const PlayableEntityVariant({required this.resolution, required this.url});
}

// Fake models
final List<Movie> fakeMovies = List.generate(10, (index) => Movie.fake());
final List<LiveChannel> fakeChannels = List.generate(
  10,
  (index) => LiveChannel.fake(),
);
final List<Series> fakeSeries = List.generate(10, (index) => Series.fake());

final List<MediaEntity> fakeCatalog = [
  ...fakeChannels,
  ...fakeMovies,
  ...fakeSeries,
];
