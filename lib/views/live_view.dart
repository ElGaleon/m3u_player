import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/components/live_channel_card.dart';
import 'package:m3u_player/components/sidebar.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';

import '../services/providers/media_content_provider.dart';

class LiveView extends ConsumerWidget {
  const LiveView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChannels = ref.watch(filteredMediaProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Live'),
      ),
      body: Row(
        children: [
          SizedBox(width: 300, child: Sidebar()),
          Flexible(
            flex: 3,
            child: asyncChannels.when(
              data: (data) => data.content.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Nessun file M3U caricato',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int columns = (constraints.maxWidth / 300).floor();
                        return GridView.builder(
                          cacheExtent: 500,
                          padding: EdgeInsetsGeometry.all(24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 16 / 9,
                              ),
                          itemCount: data.content.length,
                          itemBuilder: (context, index) {
                            final item = data.content[index];
                            return InkWell(
                              onTap: () {
                                ref
                                    .read(selectedMediaContentProvider.notifier)
                                    .update(item);
                                context.push('/player', extra: item);
                              },
                              child: LiveChannelCard(
                                channel: item,
                                currentProgram: 'Le Iene',
                                progress: 0.5,
                              ),
                            );
                          },
                        );
                      },
                    ),
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
