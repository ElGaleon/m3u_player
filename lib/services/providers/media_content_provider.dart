import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:m3u_player/utils/m3u_parser.dart';

import 'package:m3u_player/model/group_category.dart';
import 'package:m3u_player/model/media_content_type.dart';
import 'package:m3u_player/services/providers/file_filter_provider.dart';

import 'package:m3u_player/model/media_entity.dart';

///
/// This provider will return all the media content from the uploaded file
///
final asyncAllMediaEntityListProvider =
    FutureProvider.autoDispose<List<MediaEntity>>((ref) async {
      final path = ref.watch(pathProvider);
      if (path == null || path.isEmpty) return [];
      final fileExists = await File(path).exists();
      if (!fileExists) {
        ref.read(pathProvider.notifier).clearPath();
        return [];
      }
      return await compute(M3uParser.parseFromFile, path);
    });

final asyncCategoriesProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final allMedia = await ref.watch(asyncAllMediaEntityListProvider.future);
  final mediaType = ref.watch(selectedMediaTypeProvider);
  return allMedia
      .where((media) {
        return switch (mediaType) {
          MediaContentType.live => media is LiveChannel,
          MediaContentType.movie => media is Movie,
          MediaContentType.series => media is Series,
          MediaContentType.unknown => false,
          null => throw UnimplementedError(),
        };
      })
      .map((media) => media.group)
      .toSet();
});

final asyncGroupedCategoryProvider =
    FutureProvider.autoDispose<GroupedCategoryMap>((ref) async {
      GroupedCategoryMap result = GroupedCategoryMap(value: {});
      final categories = await ref.watch(asyncCategoriesProvider.future);
      final selectedMediaType = ref.watch(selectedMediaTypeProvider);
      if (categories.isEmpty) return result;

      for (final category in categories) {
        final group = GroupClassifier.classify(
          category,
          selectedMediaType ?? MediaContentType.movie,
        );
        result.value.putIfAbsent(group, () => []).add(category);
      }
      return result;
    });

final filteredMediaProvider = FutureProvider.autoDispose<List<MediaEntity>>((
  ref,
) async {
  var allMedia = await ref.watch(asyncAllMediaEntityListProvider.future);
  final filter = ref.watch(fileFilterProvider);
  final search = ref.watch(searchMediaContentProvider).toLowerCase();
  final mediaType = ref.watch(selectedMediaTypeProvider);

  if (search.isNotEmpty) {
    var didDispose = false;
    ref.onDispose(() => didDispose = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (didDispose) return [];
  }

  return allMedia.where((item) {
    bool matchesType = switch (mediaType) {
      MediaContentType.live => item is LiveChannel,
      MediaContentType.movie => item is Movie,
      MediaContentType.series => item is Series,
      MediaContentType.unknown => false,
      null => true,
    };
    if (!matchesType) return false;

    if (filter != null && item.group != filter) return false;

    if (search.isNotEmpty && !item.title.toLowerCase().contains(search) ||
        item.title.contains('----')) {
      return false;
    }

    return true;
  }).toList();
});

final currentSeasonProvider = StateProvider.autoDispose<int>((ref) => 1);

final selectedSeriesProvider = StateProvider<Series?>((ref) => null);

class SelectedMediaTypeNotifier extends Notifier<MediaContentType?> {
  @override
  MediaContentType? build() => null;

  Future<void> update(MediaContentType type) async => state = type;

  Future<void> clearFilter() async => state = null;
}

final selectedMediaTypeProvider =
    NotifierProvider<SelectedMediaTypeNotifier, MediaContentType?>(
      () => SelectedMediaTypeNotifier(),
    );

final searchMediaContentProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

final asyncMediaEntityByTypeProvider = FutureProvider.autoDispose
    .family<List<MediaEntity>, MediaContentType>((ref, type) async {
      final allMedia = await ref.watch(asyncAllMediaEntityListProvider.future);
      return allMedia.where((media) {
        return switch (type) {
          MediaContentType.live => media is LiveChannel,
          MediaContentType.movie => media is Movie,
          MediaContentType.series => media is Series,
          MediaContentType.unknown => false,
        };
      }).toList();
    });
