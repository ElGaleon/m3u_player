import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/components/series_card.dart';
import 'package:m3u_player/views/components/series_details_dialog.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';

import 'package:m3u_player/model/media_entity.dart';

class SeriesGrid extends ConsumerWidget {
  final List<Series> seriesList;

  const SeriesGrid({super.key, required this.seriesList});

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
      itemCount: seriesList.length,
      itemBuilder: (context, index) {
        var series = seriesList[index];
        bool isHovered = false;
        final imdbMetadataAsync = ref.watch(imdbMetadataProvider(series.title));
        return StatefulBuilder(
          builder: (context, setState) {
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: AnimatedScale(
                scale: (isHovered) ? 1.05 : 1,
                duration: const Duration(milliseconds: 200),
                child: imdbMetadataAsync.when(
                  data: (data) {
                    series = series.copyWith(logo: data?.poster);
                    return SeriesCard(
                      series: series,
                      onTap: () {
                        ref.read(selectedSeriesProvider.notifier).state =
                            series;
                        ref.read(currentSeasonProvider.notifier).state =
                            series.seasons.keys.first;
                        showShadDialog(
                          context: context,
                          builder: (context) {
                            return SeriesDetailsDialog(metadata: data);
                          },
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return SizedBox.shrink();
                  },
                  loading: () {
                    return Skeletonizer(
                      enabled: true,
                      child: SeriesCard(series: series),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
