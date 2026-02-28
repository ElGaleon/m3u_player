import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/model/channel.dart';

class SelectedChannelNotifier extends StateNotifier<Channel?> {
  SelectedChannelNotifier(super.state);

  Future<void> update(Channel channel) async {
    state = channel;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final selectedChannelProvider =
    StateNotifierProvider<SelectedChannelNotifier, Channel?>(
      (ref) => SelectedChannelNotifier(null),
    );
