import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/media_entity.dart';

class SelectedMediaEntityNotifier extends Notifier<MediaEntity?> {
  @override
  MediaEntity? build() => null;

  Future<void> update(MediaEntity media) async {
    state = media;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedMediaEntityProvider =
    NotifierProvider<SelectedMediaEntityNotifier, MediaEntity?>(
      () => SelectedMediaEntityNotifier(),
    );
