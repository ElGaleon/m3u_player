import 'package:m3u_player/model/media_content.dart';

extension MovieContent on MediaContent {
  String? get year {
    final match = RegExp(r'\((\d{4})\)').firstMatch(name);
    return match?.group(1);
  }

  String? get resolution {
    final match = RegExp(
      r'(4[kK]|HD|FullHD|1080p|720p)$',
    ).firstMatch(name.trim());
    return match?.group(0)?.toUpperCase();
  }
}
