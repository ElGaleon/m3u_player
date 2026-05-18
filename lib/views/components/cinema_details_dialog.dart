import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/model/imdb_metadata.dart';
import 'package:m3u_player/model/media_details.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/model/movie_metadata.dart';
import 'package:m3u_player/model/playback_request.dart';
import 'package:m3u_player/services/providers/library_provider.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';
import 'package:m3u_player/views/components/poster_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CinemaDetailsDialog extends ConsumerWidget {
  final ImdbMetadata? metadata;

  const CinemaDetailsDialog({super.key, this.metadata});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMediaEntity = ref.watch(selectedMediaEntityProvider);
    if (selectedMediaEntity == null) {
      return const Dialog(child: Padding(padding: EdgeInsets.all(24)));
    }

    final asyncDetails = ref.watch(mediaDetailsProvider(selectedMediaEntity));
    final details = asyncDetails.value;
    final posterUrl = _bestPosterUrl(
      details?.metadata?.poster,
      details?.imdb?.poster,
      metadata?.poster,
    );
    final library = ref.watch(libraryProvider);
    final series = ref.watch(selectedSeriesProvider);
    final selectedSeason = ref.watch(currentSeasonProvider);
    final seasonsList = series?.seasons.keys.toList() ?? [];
    final episodes = series?.seasons[selectedSeason] ?? [];
    final firstPlayable = selectedMediaEntity is PlayableEntity
        ? selectedMediaEntity
        : episodes.firstOrNull;
    final isFavorite = library.isFavorite(selectedMediaEntity);
    final isCompact = context.mediaQuery.size.width < 760;

    return Dialog(
      insetPadding: EdgeInsets.all(isCompact ? 12 : 24),
      constraints: BoxConstraints(
        maxWidth: isCompact ? double.infinity : 1100,
        maxHeight: context.mediaQuery.size.height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: isCompact
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 220,
                        child: _PosterHero(
                          media: selectedMediaEntity,
                          urlPoster: posterUrl,
                        ),
                      ),
                    ),
                    _DetailsContent(
                      media: selectedMediaEntity,
                      metadata: details?.metadata,
                      trailer: details?.trailer,
                      isLoading: asyncDetails.isLoading,
                      episodes: episodes,
                      seasonsList: seasonsList,
                      selectedSeason: selectedSeason,
                      firstPlayable: firstPlayable,
                      isFavorite: isFavorite,
                    ),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _PosterHero(
                        media: selectedMediaEntity,
                        urlPoster: posterUrl,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: _DetailsContent(
                        media: selectedMediaEntity,
                        metadata: details?.metadata,
                        trailer: details?.trailer,
                        isLoading: asyncDetails.isLoading,
                        episodes: episodes,
                        seasonsList: seasonsList,
                        selectedSeason: selectedSeason,
                        firstPlayable: firstPlayable,
                        isFavorite: isFavorite,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
      ),
    );
  }
}

String? _bestPosterUrl(String? primary, String? secondary, String? fallback) {
  for (final value in [primary, secondary, fallback]) {
    if (value != null && value.trim().isNotEmpty && value != 'N/A') {
      return value;
    }
  }
  return null;
}

class _PosterHero extends StatelessWidget {
  final MediaEntity media;
  final String? urlPoster;

  const _PosterHero({required this.media, this.urlPoster});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${media.title}_poster',
      child: PosterCard(
        media: media,
        urlPoster: urlPoster,
        onTap: () {},
        showTextOverlay: false,
      ),
    );
  }
}

class _DetailsContent extends ConsumerWidget {
  final MediaEntity media;
  final MovieMetadata? metadata;
  final MediaTrailer? trailer;
  final bool isLoading;
  final List<Episode> episodes;
  final List<int> seasonsList;
  final int selectedSeason;
  final PlayableEntity? firstPlayable;
  final bool isFavorite;

  const _DetailsContent({
    required this.media,
    required this.metadata,
    required this.trailer,
    required this.isLoading,
    required this.episodes,
    required this.seasonsList,
    required this.selectedSeason,
    required this.firstPlayable,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMetadata =
        metadata ?? (isLoading ? MovieMetadata.fake() : null);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(
          media.title,
          style: context.textTheme.h1Large.copyWith(color: Colors.amber),
        ),
        MovieMetadataSection(media: media, metadata: displayMetadata),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ShadButton(
              height: 48,
              backgroundColor: Colors.white,
              leading: const Icon(Icons.play_arrow),
              onPressed: firstPlayable == null
                  ? null
                  : () => _playWithResolution(context, firstPlayable!),
              child: Text(media is Series ? 'Watch S1:E1' : 'Play'),
            ),
            ShadButton(
              backgroundColor: context.colorScheme.secondary,
              height: 48,
              leading: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () =>
                  ref.read(libraryProvider.notifier).toggleFavorite(media),
              child: Text(
                isFavorite ? 'Remove favorite' : 'Add to favorite',
                style: TextStyle(color: context.colorScheme.foreground),
              ),
            ),
            if (trailer != null || isLoading)
              ShadButton.outline(
                height: 48,
                leading: const Icon(Icons.smart_display_outlined),
                onPressed: trailer == null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: trailer!.url),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Trailer link copied: ${trailer!.name}',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('Copy trailer'),
              ),
          ],
        ),
        if (episodes.isNotEmpty) ...[
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Episodes', style: context.textTheme.h3),
              if (seasonsList.isNotEmpty)
                ShadSelect<int>(
                  placeholder: const Text('Select a season'),
                  initialValue: selectedSeason,
                  options: [
                    ...seasonsList.map(
                      (season) => ShadOption(
                        value: season,
                        child: Text('Season ${season.toString()}'),
                      ),
                    ),
                  ],
                  selectedOptionBuilder: (context, value) =>
                      Text('Season ${value.toString()}'),
                  onChanged: (newSeason) {
                    if (newSeason != null) {
                      ref.read(currentSeasonProvider.notifier).state =
                          newSeason;
                    }
                  },
                ),
            ],
          ),
          const Divider(),
          LayoutBuilder(
            builder: (context, constraints) {
              final listHeight = context.mediaQuery.size.height < 720
                  ? 220.0
                  : 320.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: listHeight,
                  child: ListView.builder(
                    clipBehavior: Clip.hardEdge,
                    itemCount: episodes.length,
                    itemBuilder: (context, index) {
                      final episode = episodes[index];
                      return _EpisodeTile(
                        episode: episode,
                        mediaTitle: media.title,
                        onTap: () => _playWithResolution(context, episode),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );

    if (!isLoading) return content;
    return Skeletonizer(enabled: true, child: content);
  }

  Future<void> _playWithResolution(
    BuildContext context,
    PlayableEntity media,
  ) async {
    final variant = await _selectResolution(context, media);
    if (!context.mounted || variant == null) return;
    context.push(
      '/player',
      extra: PlaybackRequest(media: media, variant: variant),
    );
  }

  Future<PlayableEntityVariant?> _selectResolution(
    BuildContext context,
    PlayableEntity media,
  ) async {
    if (media.variants.length <= 1) return media.variants.firstOrNull;
    return showDialog<PlayableEntityVariant>(
      context: context,
      builder: (context) {
        final theme = ShadTheme.of(context);
        return AlertDialog(
          title: Text('Select resolution', style: theme.textTheme.h3),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: media.variants
                  .map(
                    (variant) => ListTile(
                      leading: const Icon(Icons.high_quality_outlined),
                      title: Text(variant.resolution),
                      subtitle: Text(
                        variant.url.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).pop(variant),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;
  final String mediaTitle;
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.mediaTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.secondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          key: ValueKey(
            '${mediaTitle}_s${episode.seasonNumber}_e${episode.episodeNumber}',
          ),
          leading: Icon(
            Icons.play_arrow_rounded,
            color: theme.colorScheme.foreground,
          ),
          title: Text(
            episode.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colorScheme.foreground),
          ),
          subtitle: Text(
            'S${episode.seasonNumber}:E${episode.episodeNumber}',
            style: TextStyle(
              color: theme.colorScheme.foreground.withValues(alpha: 0.72),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class MovieMetadataSection extends StatelessWidget {
  final MovieMetadata? metadata;
  final MediaEntity media;

  const MovieMetadataSection({
    super.key,
    required this.media,
    required this.metadata,
  }) : assert(media is Series || media is Movie);

  @override
  Widget build(BuildContext context) {
    final data = metadata;
    if (data == null || data.response == 'False') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_hasValue(data.year)) _InfoChip(data.year!),
            if (_hasValue(data.runtime)) _InfoChip(data.runtime!),
            if (_hasValue(data.genre)) _InfoChip(data.genre!),
            if (_hasValue(data.rated)) _InfoChip(data.rated!),
            if (_hasValue(data.imdbRating))
              _InfoChip('IMDb ${data.imdbRating}'),
          ],
        ),
        if (_hasValue(data.plot))
          Text(
            data.plot!,
            style: TextStyle(
              color: context.colorScheme.foreground,
              height: 1.35,
            ),
          ),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            if (_hasValue(data.director))
              _InfoBlock(label: 'Director', value: data.director!),
            if (_hasValue(data.writer))
              _InfoBlock(label: 'Writer', value: data.writer!),
            if (_hasValue(data.actors))
              _InfoBlock(label: 'Cast', value: data.actors!),
            if (_hasValue(data.released))
              _InfoBlock(label: 'Released', value: data.released!),
            if (_hasValue(data.language))
              _InfoBlock(label: 'Language', value: data.language!),
            if (_hasValue(data.country))
              _InfoBlock(label: 'Country', value: data.country!),
            if (_hasValue(data.awards))
              _InfoBlock(label: 'Awards', value: data.awards!),
            if (_hasValue(data.imdbVotes))
              _InfoBlock(label: 'IMDb votes', value: data.imdbVotes!),
          ],
        ),
        if ((data.ratings ?? []).isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.ratings!
                .where(
                  (rating) =>
                      _hasValue(rating.source) && _hasValue(rating.value),
                )
                .map((rating) => _InfoChip('${rating.source}: ${rating.value}'))
                .toList(),
          ),
      ],
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty && value != 'N/A';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.primaryForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            label,
            style: context.textTheme.small.copyWith(
              color: context.colorScheme.foreground.withValues(alpha: 0.76),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(value, style: TextStyle(color: context.colorScheme.foreground)),
        ],
      ),
    );
  }
}
