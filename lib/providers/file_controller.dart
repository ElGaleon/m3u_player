import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:m3u_player/model/m3u_file.dart';
import 'package:m3u_player/providers/file_filter_provider.dart';
import 'package:m3u_player/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/channel.dart';

class FileController extends StateNotifier<M3uFile> {
  final Ref ref;

  FileController(this.ref) : super(M3uFile());

  Future<void> savePath(String path) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('path', path);
  }

  Future<void> loadFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (!mounted) return;

        final List<Channel> parsedChannels = getChannels(contents);
        if (!mounted) return;

        state = state.copyWith(
          path: path,
          channels: parsedChannels,
          groups: parsedChannels.map((c) => c.group).toSet().toList(),
          selectedGroups: {},
        );
      }
    } catch (e) {
      if (mounted) rethrow;
    }
  }

  List<Channel> getChannels(String content) {
    List<Channel> channels = [];
    List<String> lines = content.split("#");

    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('EXTINF:')) {
        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
        final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(line);
        final tvgNameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(line);
        final tvgLogoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        final List<String> values = line.split("\n");

        final group = groupMatch?.group(1) ?? '';
        final id = tvgIdMatch?.group(1) ?? '';
        final name = tvgNameMatch?.group(1) ?? '';
        final logo = tvgLogoMatch?.group(1) ?? '';
        final url = values.last;

        channels.add(
          Channel(
            id: id,
            name: name,
            group: group,
            logo: logo,
            url: Uri.parse(url),
          ),
        );
      }
    }

    return channels;
  }

  /*
  void selectFile(String path) {
    state
  }

 */
}

final fileControllerProvider = StateNotifierProvider<FileController, M3uFile>(
  (ref) => FileController(ref),
);

final loadFileProvider = FutureProvider.family<void, String>(
  (ref, path) => ref.read(fileControllerProvider.notifier).loadFile(path),
);

final asyncChannelsProvider = FutureProvider.autoDispose<List<Channel>>((
  ref,
) async {
  final filter = ref.watch(fileFilterProvider);
  final content = await ref.watch(currentFileContentProvider.future);
  if (content == null || content == '') return [];
  final channels = ref
      .watch(fileControllerProvider.notifier)
      .getChannels(content);
  if (filter != null) {
    return channels
        .where((channel) => channel.group.contains(filter))
        .toList(growable: false);
  }
  return channels;
});

final currentFileContentProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final path = ref.watch(pathProvider);
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  final fileExists = await file.exists();
  if (!fileExists) {
    ref.read(pathProvider.notifier).clearPath();
    return null;
  }

  return await file.readAsString();
});

final asyncGroupsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final content = await ref.watch(currentFileContentProvider.future);
  if (content == null || content == "") return {};
  final channels = ref
      .watch(fileControllerProvider.notifier)
      .getChannels(content);
  return channels.map((channel) => channel.group).toSet();
});
