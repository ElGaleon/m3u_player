import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/providers/file_filter_provider.dart';
import 'package:m3u_player/providers/selected_channel_provider.dart';

import '../providers/file_controller.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChannels = ref.watch(asyncChannelsProvider);
    final asyncGroups = ref.watch(asyncGroupsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: SingleChildScrollView(
              child: asyncGroups.when(
                data: (data) => Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: data.map((group) {
                      return FilterChip(
                        selected: ref.watch(fileFilterProvider) == group,
                        label: Text(group),
                        onSelected: (selected) {
                          final oldValue = ref.read(fileFilterProvider);
                          if (oldValue == group) {
                            ref.read(fileFilterProvider.notifier).clearFilter();
                          } else {
                            ref.read(fileFilterProvider.notifier).update(group);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: asyncChannels.when(
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
                        int columns = (constraints.maxWidth / 200).floor();
                        return GridView.builder(
                          padding: EdgeInsetsGeometry.all(24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8, // Space between rows
                              ),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return InkWell(
                              onTap: () {
                                ref
                                    .read(selectedChannelProvider.notifier)
                                    .update(item);
                                Navigator.pushNamed(
                                  context,
                                  '/player',
                                  arguments: item,
                                );
                              },
                              child: Card(
                                margin: EdgeInsetsGeometry.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Expanded(
                                      child: CachedNetworkImage(
                                        imageUrl: item.logo,
                                        placeholder: (context, url) => Center(
                                          child: const Icon(Icons.tv, size: 96),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                              child: const Icon(
                                                Icons.tv,
                                                size: 96,
                                              ),
                                            ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        item.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
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
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final path = await FileService().pickFile();
          if (path == null) return;
          ref.read(pathProvider.notifier).updatePath(path);
          if (!context.mounted) return;
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text('Scheduled: Catch up'),
              description: const Text('Friday, February 10, 2023 at 5:57 PM'),
              action: ShadButton.outline(
                child: const Text('Undo'),
                onPressed: () => ShadToaster.of(context).hide(),
              ),
            ),
          );
        },
        tooltip: 'Carica file M3U',
        child: const Icon(Icons.file_open),
      ),*/
    );
  }
}
