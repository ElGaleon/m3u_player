import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';
import 'package:m3u_player/views/components/poster_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:m3u_player/extensions/build_context_extensions.dart';

import '../../model/media_entity.dart';

class CinemaDetailsDialog extends ConsumerWidget {
  final ImdbMetadata? metadata;

  const CinemaDetailsDialog({super.key, this.metadata});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMediaEntity = ref.watch(selectedMediaEntityProvider);
    final asyncMovieMetadata = ref.watch(
      movieMetadataProvider(metadata?.imdbId ?? ''),
    );
    final series = ref.watch(selectedSeriesProvider);
    final selectedSeason = ref.watch(currentSeasonProvider);
    final seasonsList = series?.seasons.keys.toList() ?? [];
    final episodes = series?.seasons[selectedSeason] ?? [];
    return Dialog(
      insetPadding: EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width * 0.8,
        maxHeight: context.mediaQuery.size.height * 0.6,
        minHeight: 500,
        minWidth: 600,
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          spacing: 24,
          children: [
            Flexible(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Hero(
                  tag: '${selectedMediaEntity?.title}_poster',
                  child: PosterCard(
                    media: selectedMediaEntity!,
                    onTap: () {},
                    showTextOverlay: false,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedMediaEntity.title,
                          style: context.textTheme.h1Large.copyWith(
                            color: Colors.amber,
                          ),
                        ),
                        if (metadata != null)
                          Text(
                            metadata!.year.toString(),
                            style: context.textTheme.h3,
                          ),
                        MetaData(
                          metaData: 'Movie metadata',
                          child: asyncMovieMetadata.when(
                            data: (data) {
                              return IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  spacing: 16,
                                  children: [
                                    if (selectedMediaEntity is Series)
                                      Text(
                                        selectedMediaEntity.resolutions.join(
                                          ", ",
                                        ),
                                      ),
                                    Text(data?.actors ?? ''),
                                    Text(data?.director ?? ''),
                                    SizedBox(
                                      child: Text(data?.imdbRating ?? ''),
                                    ),
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
                        ),
                        if (seasonsList.isNotEmpty)
                          ShadSelect<int>(
                            placeholder: const Text('Select a season'),
                            initialValue: selectedSeason,
                            options: [
                              ...seasonsList.map(
                                (e) => ShadOption(
                                  value: e,
                                  child: Text("Season ${e.toString()}"),
                                ),
                              ),
                            ],
                            selectedOptionBuilder: (context, value) =>
                                Text("Stagione ${value.toString()}"),
                            onChanged: (newSeason) {
                              if (newSeason != null) {
                                ref.read(currentSeasonProvider.notifier).state =
                                    newSeason;
                              }
                            },
                          ),
                        const Divider(),

                        Expanded(
                          child: ListView.builder(
                            itemCount: episodes.length,
                            itemBuilder: (context, index) {
                              final episode = episodes[index];

                              return ListTile(
                                leading: const Icon(Icons.play_arrow_rounded),
                                title: Text(episode.title),
                                subtitle: Text(
                                  "Press Play to view this episode",
                                ),
                                onTap: () {
                                  ref
                                      .read(
                                        selectedMediaEntityProvider.notifier,
                                      )
                                      .update(episode);
                                  context.push('/player', extra: episode);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: ShadButton(
                      child: Text('Play'),
                      onPressed: () =>
                          context.push('/player', extra: selectedMediaEntity),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
