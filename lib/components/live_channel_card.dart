import 'package:flutter/material.dart';
import 'package:m3u_player/model/media_content.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LiveChannelCard extends StatelessWidget {
  final MediaContent channel;
  final String currentProgram;
  final double progress; // valore da 0.0 a 1.0

  const LiveChannelCard({
    super.key,
    required this.channel,
    required this.currentProgram,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(child: Image.network(channel.logo, height: 60)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.muted,
                    color: Colors.amberAccent,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  style: theme.textTheme.muted.copyWith(fontSize: 10),
                ),
                Text(
                  currentProgram,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
