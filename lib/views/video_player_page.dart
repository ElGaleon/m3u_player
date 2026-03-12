import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends StatefulWidget {
  final PlayableEntity media;

  const VideoPlayerPage({super.key, required this.media});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    try {
      player.open(Media(widget.media.variants.first.url.toString()));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media.title),
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: Video(
          filterQuality: FilterQuality.high,
          controller: controller,
          subtitleViewConfiguration: const SubtitleViewConfiguration(
            style: TextStyle(
              height: 1.4,
              fontSize: 24.0,
              letterSpacing: 0.0,
              wordSpacing: 0.0,
              color: Color(0xffffffff),
              fontWeight: FontWeight.normal,
              backgroundColor: Color(0xaa000000),
            ),
            textAlign: TextAlign.center,
            padding: EdgeInsets.all(24.0),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
