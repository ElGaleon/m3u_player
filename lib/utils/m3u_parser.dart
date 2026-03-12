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
    r'(4k|4K|QHD|FHD|HD|SD|FullHD|1080p|720p)$',
  );

  static Future<List<MediaEntity>> parseFromFile(String filePath) async {
    List<MediaEntity> catalog = [];
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
              currentId: currentId,
              currentName: currentName,
              currentGroup: currentGroup,
              currentLogo: currentLogo,
              uri: uri,
            );
          case MediaContentType.movie:
            _parseMovie(
              catalog: catalog,
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
        ),
      );
    }

    return catalog;
  }

  static void _parseChannel({
    required List<MediaEntity> catalog,
    required String currentId,
    required String currentName,
    required String currentGroup,
    required String currentLogo,
    required Uri uri,
  }) {
    final resolutionMatch = _resolutionRegex.firstMatch(currentName);
    final resolution = resolutionMatch?.group(1) ?? 'SD';
    final indexFound = catalog.indexWhere(
      (channel) => channel is LiveChannel && channel.title == currentName,
    );

    String cleanTitle = currentName.replaceAll(_resolutionRegex, '').trim();

    if (indexFound != -1) {
      final channelFound = catalog[indexFound] as LiveChannel;

      final newVariant = PlayableEntityVariant(
        resolution: resolution,
        url: uri,
      );
      catalog[indexFound] = channelFound.copyWith(
        variants: [...channelFound.variants, newVariant],
      );
    } else {
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
    required String currentId,
    required String currentName,
    required String currentGroup,
    required String currentLogo,
    required Uri uri,
  }) {
    final yearMatch = _yearRegex.firstMatch(currentName);
    final resolutionMatch = _resolutionRegex.firstMatch(currentName);
    final resolution = resolutionMatch?.group(1) ?? 'SD';
    String cleanTitle = currentName
        .replaceAll(_resolutionRegex, '')
        .replaceAll(_yearRegex, '')
        .trim();
    final indexFound = catalog.indexWhere(
      (movie) =>
          (movie is Movie &&
          movie.title == currentName &&
          currentId == movie.id),
    );

    final newVariant = PlayableEntityVariant(resolution: resolution, url: uri);

    if (indexFound != -1) {
      final movieFound = catalog[indexFound] as Movie;
      catalog[indexFound] = movieFound.copyWith(
        variants: [...movieFound.variants, newVariant],
      );
    } else {
      catalog.add(
        Movie(
          id: currentId,
          title: cleanTitle,
          logo: currentLogo,
          year: yearMatch?.group(1),
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
    final resolution = resolutionMatch?.group(1) ?? 'SD';
    final int seasonNumber = seriesMatch != null
        ? int.parse(seriesMatch.group(1)!)
        : 1;
    final int episodeNumber = seriesMatch != null
        ? int.parse(seriesMatch.group(2)!)
        : 0;

    final newVariant = PlayableEntityVariant(resolution: resolution, url: uri);

    String cleanTitle = currentName
        .replaceAll(_resolutionRegex, '')
        .replaceAll(_seriesRegex, '')
        .replaceAll(_yearRegex, '')
        .trim();

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
      cleanTitle,
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
      final series = seriesMap[cleanTitle] as Series;
      final seasonToUpdate = series.seasons[seasonNumber] as List<Episode>;
      final episodeIndex = seasonToUpdate.indexWhere(
        (episode) => episode.id == currentId,
      );
      final updatedEpisode = episode.copyWith(
        variants: [...episode.variants, newVariant],
      );
      seasonToUpdate[episodeIndex] = updatedEpisode;
      seriesMap[cleanTitle]?.seasons.update(
        seasonNumber,
        (value) => seasonToUpdate,
      );
    } else {
      // New Season and/or Episode
      seriesMap[cleanTitle]!.seasons.putIfAbsent(seasonNumber, () => []);
      seriesMap[cleanTitle]!.seasons[seasonNumber]!.add(episode);
    }
  }
}
