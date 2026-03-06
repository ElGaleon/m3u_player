import 'dart:convert';
import 'dart:io';

import '../model/media_content.dart';
import '../model/media_content_type.dart';

class M3uParser {
  static final _groupRegex = RegExp(r'group-title="([^"]*)"');
  static final _idRegex = RegExp(r'tvg-id="([^"]*)"');
  static final _nameRegex = RegExp(r'tvg-name="([^"]*)"');
  static final _logoRegex = RegExp(r'tvg-logo="([^"]*)"');

  static Future<MediaContentList> parseFromFile(String filePath) async {
    MediaContentList list = MediaContentList(content: []);
    final file = File(filePath);

    final linesStream = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var currentGroup = '';
    var currentId = '';
    var currentName = '';
    var currentLogo = '';

    await for (String line in linesStream) {
      line = line.trim();

      if (line.startsWith('#EXTINF:')) {
        currentGroup = _groupRegex.firstMatch(line)?.group(1) ?? '';
        currentId = _idRegex.firstMatch(line)?.group(1) ?? '';
        currentName = _nameRegex.firstMatch(line)?.group(1) ?? '';
        currentLogo = _logoRegex.firstMatch(line)?.group(1) ?? '';

        if (currentName.isEmpty && line.contains(',')) {
          currentName = line.split(',').last.trim();
        }
      } else if (!line.startsWith('#')) {
        final url = line;
        final type = MediaContentType.classify(url);

        list.content.add(
          MediaContent(
            id: currentId,
            name: currentName,
            type: type,
            group: currentGroup,
            logo: currentLogo,
            url: Uri.parse(url),
          ),
        );

        currentGroup = '';
        currentId = '';
        currentName = '';
        currentLogo = '';
      }
    }

    return list;
  }
}
