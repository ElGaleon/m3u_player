import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/model/media_content.dart';

class SelectedChannelNotifier extends StateNotifier<MediaContent?> {
  SelectedChannelNotifier(super.state);

  Future<void> update(MediaContent channel) async {
    state = channel;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedMediaContentProvider =
    StateNotifierProvider<SelectedChannelNotifier, MediaContent?>(
      (ref) => SelectedChannelNotifier(null),
    );
