import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/model/m3u_file.dart';
import 'package:m3u_player/model/series.dart';
import 'package:m3u_player/providers/file_filter_provider.dart';
import 'package:m3u_player/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/media_content.dart';
import '../model/media_content_type.dart';

class FileController extends StateNotifier<M3uFile> {
  final Ref ref;

  FileController(this.ref) : super(M3uFile());

  Future<void> savePath(String path) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('path', path);
  }

  Future<void> loadFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (!mounted) return;

        final List<MediaContent> parsedChannels = await compute(
          getAllMediaContents,
          contents,
        );
        if (!mounted) return;

        state = state.copyWith(
          path: path,
          channels: parsedChannels,
          groups: parsedChannels.map((c) => c.group).toSet().toList(),
          selectedGroups: {},
        );
      }
    } catch (e) {
      if (mounted) rethrow;
    }
  }

  List<MediaContent> getAllMediaContents(String content) {
    List<MediaContent> channels = [];
    List<String> lines = content.split("#");

    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('EXTINF:')) {
        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
        final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(line);
        final tvgNameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(line);
        final tvgLogoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        final List<String> values = line.split("\n");

        final group = groupMatch?.group(1) ?? '';
        final id = tvgIdMatch?.group(1) ?? '';
        final name = tvgNameMatch?.group(1) ?? '';
        final logo = tvgLogoMatch?.group(1) ?? '';
        final url = values.last;
        final type = identifyContentType(url);

        channels.add(
          MediaContent(
            id: id,
            name: name,
            type: type,
            group: group,
            logo: logo,
            url: Uri.parse(url),
          ),
        );
      }
    }

    return channels;
  }
}

final rawMediaListProvider = FutureProvider.autoDispose<List<MediaContent>>((
  ref,
) async {
  final content = await ref.watch(currentFileContentProvider.future);
  if (content == null || content.isEmpty) return [];
  return ref.read(fileControllerProvider.notifier).getAllMediaContents(content);
});

final fileControllerProvider = StateNotifierProvider<FileController, M3uFile>(
  (ref) => FileController(ref),
);

final loadFileProvider = FutureProvider.family<void, String>(
  (ref, path) => ref.read(fileControllerProvider.notifier).loadFile(path),
);

final asyncAllMediaProvider = FutureProvider.autoDispose<List<MediaContent>>((
  ref,
) async {
  final filter = ref.watch(fileFilterProvider);
  final content = await ref.watch(currentFileContentProvider.future);
  if (content == null || content == '') return [];
  final channels = ref
      .watch(fileControllerProvider.notifier)
      .getAllMediaContents(content);
  if (filter != null) {
    return channels
        .where((channel) => channel.group.contains(filter))
        .toList(growable: false);
  }
  return channels;
});

final asyncLiveChannelsProvider =
    FutureProvider.autoDispose<List<MediaContent>>((ref) async {
      final allMedia = await ref.watch(asyncAllMediaProvider.future);
      return allMedia.where((media) => media.isLive).toList();
    });

final currentFileContentProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final path = ref.watch(pathProvider);
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  final fileExists = await file.exists();
  if (!fileExists) {
    ref.read(pathProvider.notifier).clearPath();
    return null;
  }

  return await file.readAsString();
});

final asyncGroupsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final allMedia = await ref.watch(rawMediaListProvider.future);
  final mediaType = ref.watch(selectedMediaTypeProvider);
  return allMedia
      .where((media) => media.type == mediaType)
      .map((media) => media.group)
      .toSet();
});

final filteredMediaProvider = FutureProvider.autoDispose<List<MediaContent>>((
  ref,
) async {
  var allMedia = await ref.watch(rawMediaListProvider.future);
  final filter = ref.watch(fileFilterProvider);
  final mediaType = ref.watch(selectedMediaTypeProvider);

  allMedia.where((media) => !media.name.startsWith('---'));

  return allMedia.where((item) {
    bool matchesCategory = true;
    switch (mediaType) {
      case MediaContentType.live:
        matchesCategory = item.isLive;
        break;
      case MediaContentType.movie:
        matchesCategory = item.isMovie;
        break;
      case MediaContentType.series:
        matchesCategory = item.isSeries;
      default:
        throw UnimplementedError();
    }

    bool matchesGroup = filter == null || item.group == filter;

    return matchesCategory && matchesGroup;
  }).toList();
});

final organizedSeriesProvider = FutureProvider.autoDispose<Map<String, Series>>(
  (ref) async {
    // 1. Osserva i dati grezzi
    final seriesMedia = await ref.watch(filteredMediaProvider.future);

    final Map<String, Series> seriesMap = {};
    final seriesRegex = RegExp(r'S(\d+)\s+E(\d+)', caseSensitive: false);

    for (var item in seriesMedia) {
      if (!item.isSeries) continue;

      final match = seriesRegex.firstMatch(item.name);

      // Pulizia del titolo: "Zorro S02 E33" -> "Zorro"
      // Usiamo la regex per dividere il nome al primo tag Sxx
      final cleanTitle = item.name
          .split(RegExp(r'S\d+', caseSensitive: false))
          .first
          .trim();

      final seasonNum = match != null ? int.parse(match.group(1)!) : 1;

      // Se la serie non esiste ancora nella mappa, la creiamo
      seriesMap.putIfAbsent(
        cleanTitle,
        () => Series(
          title: cleanTitle,
          logo: item.logo,
          group: item.group,
          seasons: {},
        ),
      );

      // Aggiungiamo l'episodio alla stagione corretta
      seriesMap[cleanTitle]!.seasons.putIfAbsent(seasonNum, () => []);
      seriesMap[cleanTitle]!.seasons[seasonNum]!.add(item);
    }

    // Opzionale: Ordiniamo gli episodi per ogni stagione
    for (var series in seriesMap.values) {
      for (var season in series.seasons.values) {
        season.sort((a, b) => a.name.compareTo(b.name));
      }
    }

    return seriesMap;
  },
);

final currentSeasonProvider = StateProvider.autoDispose<int>((ref) => 1);

final selectedSeriesProvider = StateProvider<Series?>((ref) => null);
