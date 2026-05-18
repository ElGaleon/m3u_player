import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

String mediaLibraryKey(MediaEntity media) {
  if (media.id.trim().isNotEmpty) return '${media.runtimeType}:${media.id}';
  return '${media.runtimeType}:${media.title}:${media.group}';
}

class LibraryState {
  final Set<String> favoriteKeys;
  final List<String> continueWatchingKeys;

  const LibraryState({
    required this.favoriteKeys,
    required this.continueWatchingKeys,
  });

  bool isFavorite(MediaEntity media) =>
      favoriteKeys.contains(mediaLibraryKey(media));

  LibraryState copyWith({
    Set<String>? favoriteKeys,
    List<String>? continueWatchingKeys,
  }) {
    return LibraryState(
      favoriteKeys: favoriteKeys ?? this.favoriteKeys,
      continueWatchingKeys: continueWatchingKeys ?? this.continueWatchingKeys,
    );
  }
}

class LibraryNotifier extends Notifier<LibraryState> {
  late final SharedPreferences _preferences;
  static const _favoritesKey = 'library_favorites';
  static const _continueWatchingKey = 'library_continue_watching';

  @override
  LibraryState build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return LibraryState(
      favoriteKeys: (_preferences.getStringList(_favoritesKey) ?? []).toSet(),
      continueWatchingKeys:
          _preferences.getStringList(_continueWatchingKey) ?? [],
    );
  }

  Future<void> toggleFavorite(MediaEntity media) async {
    final key = mediaLibraryKey(media);
    final next = {...state.favoriteKeys};
    next.contains(key) ? next.remove(key) : next.add(key);
    state = state.copyWith(favoriteKeys: next);
    await _preferences.setStringList(_favoritesKey, next.toList()..sort());
  }

  Future<void> markAsPlayed(PlayableEntity media) async {
    final key = mediaLibraryKey(media);
    final next = [
      key,
      ...state.continueWatchingKeys.where((existing) => existing != key),
    ].take(30).toList();
    state = state.copyWith(continueWatchingKeys: next);
    await _preferences.setStringList(_continueWatchingKey, next);
  }

  Future<void> clearFavorites() async {
    state = state.copyWith(favoriteKeys: {});
    await _preferences.remove(_favoritesKey);
  }

  Future<void> clearContinueWatching() async {
    state = state.copyWith(continueWatchingKeys: []);
    await _preferences.remove(_continueWatchingKey);
  }
}

final libraryProvider = NotifierProvider<LibraryNotifier, LibraryState>(
  () => LibraryNotifier(),
);

final favoriteMediaProvider = FutureProvider.autoDispose<List<MediaEntity>>((
  ref,
) async {
  final library = ref.watch(libraryProvider);
  final allMedia = await ref.watch(asyncAllMediaEntityListProvider.future);
  return allMedia
      .where((media) => library.favoriteKeys.contains(mediaLibraryKey(media)))
      .toList();
});

final continueWatchingMediaProvider =
    FutureProvider.autoDispose<List<MediaEntity>>((ref) async {
      final library = ref.watch(libraryProvider);
      final allMedia = await ref.watch(asyncAllMediaEntityListProvider.future);
      final mediaByKey = {
        for (final media in allMedia) mediaLibraryKey(media): media,
      };
      return library.continueWatchingKeys
          .map((key) => mediaByKey[key])
          .nonNulls
          .toList();
    });
