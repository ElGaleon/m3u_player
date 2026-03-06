import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:riverpod/riverpod.dart';

import 'package:m3u_player/model/media_content.dart';

class PaginatedMediaNotifier extends Notifier<MediaContentList> {
  static const _contentLength = 40;

  @override
  MediaContentList build() {
    final allFiltered = ref.watch(filteredMediaProvider).value?.content ?? [];
    return MediaContentList(content: allFiltered.take(_contentLength).toList());
  }

  void loadMore() {
    final allFiltered = ref.watch(filteredMediaProvider).value?.content ?? [];
    final currentList = state.content;

    if (currentList.length < allFiltered.length) {
      final nextItems = allFiltered
          .skip(currentList.length)
          .take(_contentLength);
      state = MediaContentList(content: [...currentList, ...nextItems]);
    }
  }
}

final paginatedMediaProvider =
    NotifierProvider.autoDispose<PaginatedMediaNotifier, MediaContentList>(
      () => PaginatedMediaNotifier(),
    );
