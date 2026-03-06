import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/model/media_content.dart';

class SelectedMediaContentNotifier extends StateNotifier<MediaContent?> {
  SelectedMediaContentNotifier(super.state);

  Future<void> update(MediaContent channel) async {
    state = channel;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedMediaContentProvider =
    StateNotifierProvider<SelectedMediaContentNotifier, MediaContent?>(
      (ref) => SelectedMediaContentNotifier(null),
    );
