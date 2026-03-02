import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/components/series_card.dart';
import 'package:m3u_player/model/series.dart';

import '../providers/file_controller.dart';

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
        final series = seriesList[index];
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
                    ref.read(selectedSeriesProvider.notifier).state = series;
                    ref.read(currentSeasonProvider.notifier).state =
                        series.seasons.keys.first;
                    context.push('/series-details');
                  },
                  child: SeriesCard(series: series),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
