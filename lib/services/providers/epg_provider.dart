import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/epg_program.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpgPathNotifier extends Notifier<String?> {
  late final SharedPreferences _preferences;
  static const _key = 'epg_path';

  @override
  String? build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return _preferences.getString(_key);
  }

  Future<void> updatePath(String path) async {
    state = path;
    await _preferences.setString(_key, path);
  }

  Future<void> clearPath() async {
    state = null;
    await _preferences.remove(_key);
  }
}

final epgPathProvider = NotifierProvider<EpgPathNotifier, String?>(
  () => EpgPathNotifier(),
);

final epgProgramsProvider = FutureProvider.autoDispose<List<EpgProgram>>((
  ref,
) async {
  final path = ref.watch(epgPathProvider);
  if (path == null || path.isEmpty) return [];
  final file = File(path);
  if (!await file.exists()) {
    ref.read(epgPathProvider.notifier).clearPath();
    return [];
  }
  return EpgParser.parse(await file.readAsString());
});

final currentProgramProvider = FutureProvider.autoDispose
    .family<EpgProgram?, LiveChannel>((ref, channel) async {
      final programs = await ref.watch(epgProgramsProvider.future);
      final now = DateTime.now();
      final channelKeys = {
        channel.id,
        channel.title,
      }.where((value) => value.trim().isNotEmpty).toSet();
      return programs
          .where(
            (program) =>
                channelKeys.contains(program.channelId) &&
                program.isAiringAt(now),
          )
          .firstOrNull;
    });

class EpgParser {
  static final _programRegex = RegExp(
    r'<programme\b([^>]*)>([\s\S]*?)</programme>',
    caseSensitive: false,
  );
  static final _channelRegex = RegExp(r'channel="([^"]*)"');
  static final _startRegex = RegExp(r'start="([^"]*)"');
  static final _stopRegex = RegExp(r'stop="([^"]*)"');
  static final _titleRegex = RegExp(
    r'<title(?:\s[^>]*)?>([\s\S]*?)</title>',
    caseSensitive: false,
  );
  static final _descriptionRegex = RegExp(
    r'<desc(?:\s[^>]*)?>([\s\S]*?)</desc>',
    caseSensitive: false,
  );

  static List<EpgProgram> parse(String xml) {
    return _programRegex
        .allMatches(xml)
        .map((match) {
          final attributes = match.group(1) ?? '';
          final body = match.group(2) ?? '';
          final channelId =
              _channelRegex.firstMatch(attributes)?.group(1) ?? '';
          final title = _cleanText(
            _titleRegex.firstMatch(body)?.group(1) ?? '',
          );
          final description = _cleanText(
            _descriptionRegex.firstMatch(body)?.group(1) ?? '',
          );
          final start = _parseXmlTvDate(
            _startRegex.firstMatch(attributes)?.group(1),
          );
          final stop = _parseXmlTvDate(
            _stopRegex.firstMatch(attributes)?.group(1),
          );
          if (channelId.isEmpty ||
              title.isEmpty ||
              start == null ||
              stop == null) {
            return null;
          }
          return EpgProgram(
            channelId: channelId,
            title: title,
            description: description.isEmpty ? null : description,
            start: start,
            stop: stop,
          );
        })
        .nonNulls
        .toList();
  }

  static DateTime? _parseXmlTvDate(String? value) {
    if (value == null || value.length < 14) return null;
    final normalized =
        '${value.substring(0, 4)}-'
        '${value.substring(4, 6)}-'
        '${value.substring(6, 8)}T'
        '${value.substring(8, 10)}:'
        '${value.substring(10, 12)}:'
        '${value.substring(12, 14)}';
    return DateTime.tryParse(normalized);
  }

  static String _cleanText(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
