import 'package:m3u_player/model/channel.dart';

class M3uFile {
  final String? path;
  final List<Channel> channels;
  final List<String> groups;
  final Set<String>? selectedGroups;

  M3uFile({
    this.path,
    this.channels = const [],
    this.groups = const [],
    this.selectedGroups,
  });

  M3uFile copyWith({
    String? path,
    List<Channel>? channels,
    List<String>? groups,
    Set<String>? selectedGroups,
  }) => M3uFile(
    path: path ?? this.path,
    channels: channels ?? this.channels,
    groups: groups ?? this.groups,
    selectedGroups: selectedGroups ?? this.selectedGroups,
  );
}
