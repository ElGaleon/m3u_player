import 'package:m3u_player/model/media_content_type.dart';

class MediaContent {
  final String id;
  final String name;
  final MediaContentType type;
  final String logo;
  final Uri url;
  final String group;

  const MediaContent({
    required this.id,
    required this.name,
    required this.type,
    required this.group,
    required this.logo,
    required this.url,
  });

  String get cleanTitle {
    String clean = name.split('(')[0].trim();
    return clean.isEmpty ? name : clean;
  }

  MediaContent copyWith({
    String? id,
    String? name,
    MediaContentType? type,
    String? logo,
    Uri? url,
    String? group,
  }) => MediaContent(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    logo: logo ?? this.logo,
    url: url ?? this.url,
    group: group ?? this.group,
  );

  bool get isLive => type == MediaContentType.live;

  bool get isMovie => type == MediaContentType.movie;

  bool get isSeries => type == MediaContentType.series;
}
