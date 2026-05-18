import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/components/live_channel_card.dart';
import 'package:m3u_player/components/sidebar.dart';
import 'package:m3u_player/model/epg_program.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/epg_provider.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';

import '../services/providers/media_content_provider.dart';

class LiveView extends ConsumerWidget {
  const LiveView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChannels = ref.watch(filteredMediaProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 840;
        return Scaffold(
          drawer: isCompact
              ? const Drawer(child: SafeArea(child: Sidebar()))
              : null,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Live'),
          ),
          body: isCompact
              ? _LiveGrid(asyncChannels: asyncChannels)
              : Row(
                  children: [
                    const SizedBox(width: 300, child: Sidebar()),
                    Expanded(
                      flex: 3,
                      child: _LiveGrid(asyncChannels: asyncChannels),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _LiveGrid extends ConsumerWidget {
  final AsyncValue<List<MediaEntity>> asyncChannels;

  const _LiveGrid({required this.asyncChannels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncChannels.when(
      data: (data) => data.isEmpty
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
                final tileWidth = constraints.maxWidth < 700 ? 220 : 300;
                final columns = (constraints.maxWidth / tileWidth)
                    .floor()
                    .clamp(1, 8);
                return GridView.builder(
                  cacheExtent: 500,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index] as LiveChannel;
                    final currentProgram = ref.watch(
                      currentProgramProvider(item),
                    );
                    return InkWell(
                      onTap: () {
                        ref
                            .read(selectedMediaEntityProvider.notifier)
                            .update(item);
                        context.push('/player', extra: item);
                      },
                      child: LiveChannelCard(
                        channel: item,
                        currentProgram: currentProgram.value?.title,
                        progress: _programProgress(currentProgram.value),
                      ),
                    );
                  },
                );
              },
            ),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  double _programProgress(EpgProgram? program) {
    if (program == null) return 0;
    final now = DateTime.now();
    final total = program.stop.difference(program.start).inSeconds;
    if (total <= 0) return 0;
    final elapsed = now.difference(program.start).inSeconds;
    return (elapsed / total).clamp(0, 1);
  }
}
