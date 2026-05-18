import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:m3u_player/model/media_content_type.dart';
import 'package:m3u_player/views/components/media_content_card.dart';

import 'package:m3u_player/services/providers/media_content_provider.dart';

class HomePage extends ConsumerWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentTiles = MediaContentType.values
        .where((t) => t != MediaContentType.unknown)
        .map((type) {
          final asyncMediaEntityByType = ref.watch(
            asyncMediaEntityByTypeProvider(type),
          );
          return asyncMediaEntityByType.when(
            data: (data) {
              return MediaContentCard(type: type, length: data.length);
            },
            error: (error, stackTrace) {
              return ShadToast.destructive(
                title: const Text('ERROR'),
                description: Text(error.toString()),
              );
            },
            loading: () {
              return Skeletonizer(
                enabled: true,
                child: MediaContentCard(type: type),
              );
            },
          );
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: Colors.transparent,
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          if (isCompact) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                ...contentTiles.map(
                  (tile) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: tile,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(child: Text('Made with ❤️ by Christian Galeone')),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: contentTiles,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Made with ❤️ by Christian Galeone'),
              ),
            ],
          );
        },
      ),
    );
  }
}
