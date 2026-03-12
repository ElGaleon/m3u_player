import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:riverpod/riverpod.dart';

class PaginatedMediaNotifier extends Notifier<List<MediaEntity>> {
  static const _contentLength = 40;

  @override
  List<MediaEntity> build() {
    final allFiltered = ref.watch(filteredMediaProvider).value ?? [];
    return allFiltered.take(_contentLength).toList();
  }

  void loadMore() {
    final allFiltered = ref.watch(filteredMediaProvider).value ?? [];
    final currentList = state;

    if (currentList.length < allFiltered.length) {
      final nextItems = allFiltered
          .skip(currentList.length)
          .take(_contentLength);
      state = [...currentList, ...nextItems];
    }
  }
}

final paginatedMediaProvider =
    NotifierProvider.autoDispose<PaginatedMediaNotifier, List<MediaEntity>>(
      () => PaginatedMediaNotifier(),
    );
