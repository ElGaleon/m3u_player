import 'package:m3u_player/model/media_entity.dart';

class PlaybackRequest {
  final PlayableEntity media;
  final PlayableEntityVariant? variant;

  const PlaybackRequest({required this.media, this.variant});
}
