import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:m3u_player/utils/m3u_parser.dart';

import 'package:m3u_player/model/group_category.dart';
import 'package:m3u_player/model/media_content.dart';
import 'package:m3u_player/model/media_content_type.dart';
import 'package:m3u_player/model/series.dart';
import 'package:m3u_player/services/providers/file_filter_provider.dart';

///
/// This provider will return all the media content from the uploaded file
///
final asyncAllMediaContentListProvider =
    FutureProvider.autoDispose<MediaContentList>((ref) async {
      final path = ref.watch(pathProvider);
      if (path == null || path.isEmpty) return MediaContentList(content: []);
      final fileExists = await File(path).exists();
      if (!fileExists) {
        ref.read(pathProvider.notifier).clearPath();
        return MediaContentList(content: []);
      }
      return await compute(M3uParser.parseFromFile, path);
    });

final asyncMediaContentByTypeProvider = FutureProvider.autoDispose
    .family<List<MediaContent>, MediaContentType>((ref, type) async {
      final allMedia = await ref.watch(asyncAllMediaContentListProvider.future);
      return allMedia.content.where((media) => media.type == type).toList();
    });

final asyncCategoriesProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final allMedia = await ref.watch(asyncAllMediaContentListProvider.future);
  final mediaType = ref.watch(selectedMediaTypeProvider);
  return allMedia.content
      .where((media) => media.type == mediaType)
      .map((media) => media.group)
      .toSet();
});

final asyncGroupedCategoryProvider =
    FutureProvider.autoDispose<GroupedCategoryMap>((ref) async {
      GroupedCategoryMap result = GroupedCategoryMap(value: {});
      final categories = await ref.watch(asyncCategoriesProvider.future);
      if (categories.isEmpty) return result;

      for (final category in categories) {
        final group = GroupClassifier.classify(category);
        result.value.putIfAbsent(group, () => []).add(category);
      }
      return result;
    });

final filteredMediaProvider = FutureProvider.autoDispose<MediaContentList>((
  ref,
) async {
  var allMedia = await ref.watch(asyncAllMediaContentListProvider.future);
  final filter = ref.watch(fileFilterProvider);
  final mediaType = ref.watch(selectedMediaTypeProvider);

  final filteredList = allMedia.content.where((item) {
    if (item.name.startsWith('---')) return false;
    bool matchesCategory = item.type == mediaType;
    bool matchesGroup = filter == null || item.group == filter;
    return matchesCategory && matchesGroup;
  }).toList();

  return MediaContentList(content: filteredList);
});

final organizedSeriesProvider = FutureProvider.autoDispose<Map<String, Series>>(
  (ref) async {
    final seriesMedia = await ref.watch(filteredMediaProvider.future);

    final Map<String, Series> seriesMap = {};
    final seriesRegex = RegExp(r'S(\d+)\s+E(\d+)', caseSensitive: false);

    for (var item in seriesMedia.content) {
      if (!item.isSeries) continue;

      final match = seriesRegex.firstMatch(item.name);

      // e.g. "Zorro S02 E33" -> "Zorro"
      final cleanTitle = item.name
          .split(RegExp(r'S\d+', caseSensitive: false))
          .first
          .trim();

      final seasonNum = match != null ? int.parse(match.group(1)!) : 1;

      seriesMap.putIfAbsent(
        cleanTitle,
        () => Series(
          title: cleanTitle,
          logo: item.logo,
          group: item.group,
          seasons: {},
        ),
      );

      seriesMap[cleanTitle]!.seasons.putIfAbsent(seasonNum, () => []);
      seriesMap[cleanTitle]!.seasons[seasonNum]!.add(item);
    }

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

class SelectedMediaTypeNotifier extends Notifier<MediaContentType?> {
  @override
  MediaContentType? build() {
    return null;
  }

  Future<void> update(MediaContentType type) async {
    state = type;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedMediaTypeProvider =
    NotifierProvider<SelectedMediaTypeNotifier, MediaContentType?>(
      () => SelectedMediaTypeNotifier(),
    );
