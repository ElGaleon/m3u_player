import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/library_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  final PlayableEntity media;
  final PlayableEntityVariant? initialVariant;

  const VideoPlayerPage({super.key, required this.media, this.initialVariant});

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  late final player = Player();
  late final controller = VideoController(player);
  late PlayableEntityVariant selectedVariant =
      widget.initialVariant ?? widget.media.variants.first;

  @override
  void initState() {
    super.initState();
    _openVariant(selectedVariant);
    ref.read(libraryProvider.notifier).markAsPlayed(widget.media);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.media.title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          if (widget.media.variants.length > 1)
            PopupMenuButton<PlayableEntityVariant>(
              tooltip: 'Select quality',
              icon: const Icon(Icons.high_quality_outlined),
              initialValue: selectedVariant,
              onSelected: (variant) {
                setState(() => selectedVariant = variant);
                _openVariant(variant);
              },
              itemBuilder: (context) {
                return widget.media.variants
                    .map(
                      (variant) => PopupMenuItem(
                        value: variant,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (variant == selectedVariant)
                              const Icon(Icons.check, size: 18)
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(variant.resolution),
                          ],
                        ),
                      ),
                    )
                    .toList();
              },
            ),
        ],
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

  void _openVariant(PlayableEntityVariant variant) {
    try {
      player.open(Media(variant.url.toString()));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
