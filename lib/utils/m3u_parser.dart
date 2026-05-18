import 'dart:convert';
import 'dart:io';

import 'package:m3u_player/model/media_content_type.dart';
import 'package:m3u_player/model/media_entity.dart';

class M3uParser {
  static final _groupRegex = RegExp(r'group-title="([^"]*)"');
  static final _idRegex = RegExp(r'tvg-id="([^"]*)"');
  static final _nameRegex = RegExp(r'tvg-name="([^"]*)"');
  static final _logoRegex = RegExp(r'tvg-logo="([^"]*)"');

  static final _seriesRegex = RegExp(r'S(\d+).*?E(\d+)', caseSensitive: false);
  static final _yearRegex = RegExp(r'\((\d{4})\)');
  static final _resolutionRegex = RegExp(
    r'\b(4K|QHD|FHD|HD|SD|FullHD|1080p|720p)\b',
    caseSensitive: false,
  );

  static Future<List<MediaEntity>> parseFromFile(String filePath) async {
    List<MediaEntity> catalog = [];
    final Map<String, int> liveIndexByKey = {};
    final Map<String, int> movieIndexByKey = {};
    final Map<String, Series> seriesMap = {};
    final file = File(filePath);

    final linesStream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var currentGroup = '';
    var currentId = '';
    var currentName = '';
    var currentLogo = '';

    await for (String line in linesStream) {
      line = line.trim();

      if (line.startsWith('#EXTINF:')) {
        currentGroup = _groupRegex.firstMatch(line)?.group(1) ?? '';
        currentId = _idRegex.firstMatch(line)?.group(1) ?? '';
        currentName = _nameRegex.firstMatch(line)?.group(1) ?? '';
        currentLogo = _logoRegex.firstMatch(line)?.group(1) ?? '';

        if (currentName.isEmpty && line.contains(',')) {
          currentName = line.split(',').last.trim();
        }
      } else if (!line.startsWith('#') && line.isNotEmpty) {
        final url = line;
        final type = MediaContentType.classify(url);
        final uri = Uri.parse(url);

        switch (type) {
          case MediaContentType.live:
            _parseChannel(
              catalog: catalog,
              indexByKey: liveIndexByKey,
              currentId: currentId,
              currentName: currentName,
              currentGroup: currentGroup,
              currentLogo: currentLogo,
              uri: uri,
            );
          case MediaContentType.movie:
            _parseMovie(
              catalog: catalog,
              indexByKey: movieIndexByKey,
              currentId: currentId,
              currentName: currentName,
              currentGroup: currentGroup,
              currentLogo: currentLogo,
              uri: uri,
            );
          case MediaContentType.series:
            _parseSeries(
              catalog: catalog,
              seriesMap: seriesMap,
              currentId: currentId,
              currentName: currentName,
              currentGroup: currentGroup,
              currentLogo: currentLogo,
              uri: uri,
            );
          default:
            break;
        }

        currentGroup = '';
        currentId = '';
        currentName = '';
        currentLogo = '';
      }
    }

    for (var series in seriesMap.values) {
      series.seasons.forEach((seasonIndex, episodesList) {
        episodesList.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      });
      catalog.add(
        Series(
          id: series.id,
          title: series.title,
          logo: series.logo,
          group: series.group,
          seasons: series.seasons,
          year: series.year,
        ),
      );
    }

    return catalog;
  }

  static void _parseChannel({
    required List<MediaEntity> catalog,
    required Map<String, int> indexByKey,
    required String currentId,
    required String currentName,
    required String currentGroup,
    required String currentLogo,
    required Uri uri,
  }) {
    final resolutionMatch = _resolutionRegex.firstMatch(currentName);
    final resolution = _normalizeResolution(resolutionMatch?.group(1));
    final cleanTitle = _cleanTitle(
      currentName.replaceAll(_resolutionRegex, ''),
    );
    final key = _entityKey(cleanTitle, currentGroup);
    final indexFound = indexByKey[key];
    final newVariant = PlayableEntityVariant(resolution: resolution, url: uri);

    if (indexFound != null) {
      final channelFound = catalog[indexFound] as LiveChannel;
      catalog[indexFound] = channelFound.copyWith(
        variants: _appendVariant(channelFound.variants, newVariant),
      );
    } else {
      indexByKey[key] = catalog.length;
      catalog.add(
        LiveChannel(
          id: currentId,
          title: cleanTitle,
          logo: currentLogo,
          group: currentGroup,
          variants: [PlayableEntityVariant(resolution: resolution, url: uri)],
        ),
      );
    }
  }

  static void _parseMovie({
    required List<MediaEntity> catalog,
    required Map<String, int> indexByKey,
    required String currentId,
    required String currentName,
    required String currentGroup,
    required String currentLogo,
    required Uri uri,
  }) {
    final yearMatch = _yearRegex.firstMatch(currentName);
    final resolutionMatch = _resolutionRegex.firstMatch(currentName);
    final resolution = _normalizeResolution(resolutionMatch?.group(1));
    final cleanTitle = _cleanTitle(
      currentName.replaceAll(_resolutionRegex, '').replaceAll(_yearRegex, ''),
    );
    final year = yearMatch?.group(1);
    final key = _entityKey(cleanTitle, currentGroup, year);
    final indexFound = indexByKey[key];

    final newVariant = PlayableEntityVariant(resolution: resolution, url: uri);

    if (indexFound != null) {
      final movieFound = catalog[indexFound] as Movie;
      catalog[indexFound] = movieFound.copyWith(
        variants: _appendVariant(movieFound.variants, newVariant),
      );
    } else {
      indexByKey[key] = catalog.length;
      catalog.add(
        Movie(
          id: currentId,
          title: cleanTitle,
          logo: currentLogo,
          year: year,
          group: currentGroup,
          variants: [newVariant],
        ),
      );
    }
  }

  static void _parseSeries({
    required List<MediaEntity> catalog,
    required Map<String, Series> seriesMap,
    required String currentId,
    required String currentName,
    required String currentGroup,
    required String currentLogo,
    required Uri uri,
  }) {
    final seriesMatch = _seriesRegex.firstMatch(currentName);
    final yearMatch = _yearRegex.firstMatch(currentName);
    final resolutionMatch = _resolutionRegex.firstMatch(currentName);
    final resolution = _normalizeResolution(resolutionMatch?.group(1));
    final int seasonNumber = seriesMatch != null
        ? int.parse(seriesMatch.group(1)!)
        : 1;
    final int episodeNumber = seriesMatch != null
        ? int.parse(seriesMatch.group(2)!)
        : 0;

    final newVariant = PlayableEntityVariant(resolution: resolution, url: uri);

    final cleanTitle = _cleanTitle(
      currentName
          .replaceAll(_resolutionRegex, '')
          .replaceAll(_seriesRegex, '')
          .replaceAll(_yearRegex, ''),
    );
    final seriesKey = _entityKey(cleanTitle, currentGroup, yearMatch?.group(1));

    // Create the episode
    final episode = Episode(
      id: currentId,
      title: 'Episode $episodeNumber',
      logo: currentLogo,
      group: currentGroup,
      variants: [newVariant],
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    // Create the series if does not exist
    final insertedSeries = seriesMap.putIfAbsent(
      seriesKey,
      () => Series(
        id: currentId,
        title: cleanTitle,
        logo: currentLogo,
        group: currentGroup,
        seasons: {},
        year: yearMatch?.group(1),
      ),
    );

    // Check if the episode exists
    final existingEpisode = insertedSeries.getEpisodeBySeasonAndEpisode(
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    if (existingEpisode != null) {
      // We have to update episode, seasons and series
      final series = seriesMap[seriesKey] as Series;
      final seasonToUpdate = series.seasons[seasonNumber] as List<Episode>;
      final episodeIndex = seasonToUpdate.indexWhere(
        (episode) => episode.episodeNumber == episodeNumber,
      );
      final updatedEpisode = existingEpisode.copyWith(
        variants: _appendVariant(existingEpisode.variants, newVariant),
      );
      seasonToUpdate[episodeIndex] = updatedEpisode;
      seriesMap[seriesKey]?.seasons.update(
        seasonNumber,
        (value) => seasonToUpdate,
      );
    } else {
      // New Season and/or Episode
      seriesMap[seriesKey]!.seasons.putIfAbsent(seasonNumber, () => []);
      seriesMap[seriesKey]!.seasons[seasonNumber]!.add(episode);
    }
  }

  static List<PlayableEntityVariant> _appendVariant(
    List<PlayableEntityVariant> variants,
    PlayableEntityVariant newVariant,
  ) {
    final alreadyExists = variants.any(
      (variant) =>
          variant.resolution.toLowerCase() ==
              newVariant.resolution.toLowerCase() ||
          variant.url == newVariant.url,
    );
    if (alreadyExists) return variants;
    return [...variants, newVariant]..sort(_compareVariants);
  }

  static int _compareVariants(
    PlayableEntityVariant a,
    PlayableEntityVariant b,
  ) {
    return _resolutionWeight(
      b.resolution,
    ).compareTo(_resolutionWeight(a.resolution));
  }

  static int _resolutionWeight(String resolution) {
    return switch (resolution.toUpperCase()) {
      '4K' => 4000,
      'QHD' => 1440,
      'FULLHD' || 'FHD' || '1080P' => 1080,
      'HD' || '720P' => 720,
      'SD' => 480,
      _ => 0,
    };
  }

  static String _normalizeResolution(String? resolution) {
    return switch (resolution?.toUpperCase()) {
      null => 'SD',
      'FULLHD' => 'FHD',
      final value => value,
    };
  }

  static String _cleanTitle(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _entityKey(String title, String group, [String? year]) {
    return [
      title,
      group,
      ?year,
    ].map((part) => part.toLowerCase().trim()).join('|');
  }
}
