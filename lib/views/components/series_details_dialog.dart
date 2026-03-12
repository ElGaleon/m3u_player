import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/components/series_card.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:m3u_player/extensions/build_context_extensions.dart';

class SeriesDetailsDialog extends ConsumerWidget {
  final ImdbMetadata? metadata;
  const SeriesDetailsDialog({super.key, this.metadata});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSeries = ref.watch(selectedSeriesProvider);
    final asyncMovieMetadata = ref.watch(
      movieMetadataProvider(metadata?.imdbId ?? ''),
    );
    return ShadDialog(
      padding: EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width * 0.9,
        maxHeight: context.mediaQuery.size.height * 0.7,
        minHeight: 500,
        minWidth: 600,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        spacing: 24,
        children: [
          IntrinsicHeight(
            child: SeriesCard(
              series: selectedSeries!,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSeries.title,
                  style: context.textTheme.h1Large.copyWith(
                    color: Colors.amber,
                  ),
                ),
                if (metadata != null)
                  Text(metadata!.year.toString(), style: context.textTheme.h3),
                asyncMovieMetadata.when(
                  data: (data) {
                    return IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Text(data?.actors ?? ''),
                          Text(data?.director ?? ''),
                          Text(data?.imdbRating ?? ''),

                          Text(
                            data?.plot ?? '',
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return SizedBox.shrink();
                  },
                  loading: () {
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
