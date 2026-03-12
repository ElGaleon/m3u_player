import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:m3u_player/services/providers/paginated_media_provider.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';
import 'package:m3u_player/views/components/cinema_details_dialog.dart';
import 'package:m3u_player/views/components/poster_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show ShadToast, showShadDialog;
import 'package:skeletonizer/skeletonizer.dart' show Skeletonizer;

class CinemaGrid extends ConsumerStatefulWidget {
  final List<MediaEntity> list;

  const CinemaGrid({super.key, required this.list});

  @override
  ConsumerState<CinemaGrid> createState() => _MovieGridState();
}

class _MovieGridState extends ConsumerState<CinemaGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(paginatedMediaProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginatedList = ref.watch(paginatedMediaProvider);
    return GridView.builder(
      controller: _scrollController,
      cacheExtent: 1000,
      padding: EdgeInsetsGeometry.all(24),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2 / 3,
      ),
      itemCount: paginatedList.length,
      itemBuilder: (context, index) {
        var media = widget.list[index];
        bool isHovered = false;
        final imdbMetadataAsync = ref.watch(imdbMetadataProvider(media.title));
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
                    if (media is Series) {
                      media = (media as Series).copyWith(logo: data?.poster);
                    }
                    return Hero(
                      tag: '${media.title}_poster',
                      child: PosterCard(
                        media: media,
                        urlPoster: data?.poster,
                        onTap: () {
                          ref
                              .read(selectedMediaEntityProvider.notifier)
                              .update(media);
                          if (media is Series) {
                            ref.read(selectedSeriesProvider.notifier).state =
                                (media as Series);
                            ref.read(currentSeasonProvider.notifier).state =
                                (media as Series).seasons.keys.first;
                          }
                          showShadDialog(
                            context: context,
                            builder: (context) {
                              return CinemaDetailsDialog(metadata: data);
                            },
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    ShadToast.destructive(
                      title: Text('Error'),
                      description: Text(stackTrace.toString()),
                    );
                    return SizedBox.shrink();
                  },
                  loading: () {
                    return Skeletonizer(
                      enabled: true,
                      child: PosterCard(media: media, onTap: () {}),
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
