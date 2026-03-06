import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/components/movie_card.dart';
import 'package:m3u_player/components/series_grid.dart';
import 'package:m3u_player/components/sidebar.dart';
import 'package:m3u_player/model/media_content.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/providers/media_content_provider.dart';
import '../services/providers/selected_media_content_provider.dart';

class SeriesView extends ConsumerWidget {
  const SeriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSeries = ref.watch(organizedSeriesProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Series'),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 300, child: Sidebar()),
          Expanded(
            flex: 4,
            child: Center(
              child: asyncSeries.when(
                data: (data) {
                  final item = data.values.toList();
                  return data.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Nessun file M3U caricato',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        )
                      : SeriesGrid(seriesList: item);
                },
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => Skeletonizer(
                  enabled: true,
                  child: SeriesGrid(seriesList: []),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieGrid extends ConsumerWidget {
  final List<MediaContent> contentList;

  const MovieGrid({super.key, required this.contentList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      cacheExtent: 500,
      padding: EdgeInsetsGeometry.all(24),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2 / 3,
      ),
      itemCount: contentList.length,
      itemBuilder: (context, index) {
        final movie = contentList[index];
        bool isHovered = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: AnimatedScale(
                scale: (isHovered) ? 1.05 : 1,
                duration: const Duration(milliseconds: 200),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(selectedMediaContentProvider.notifier)
                        .update(movie);
                    context.push('/player', extra: movie);
                  },
                  child: MovieCard(movie: movie),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
