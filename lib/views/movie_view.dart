import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/components/movie_card.dart';
import 'package:m3u_player/components/sidebar.dart';
import 'package:m3u_player/model/media_content.dart';
import 'package:m3u_player/services/providers/movie_details_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/providers/media_content_provider.dart';
import '../services/providers/paginated_media_provider.dart';
import '../services/providers/selected_media_content_provider.dart';

class MovieView extends ConsumerWidget {
  const MovieView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovies = ref.watch(filteredMediaProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Movies'),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 300, child: Sidebar()),
          Expanded(
            flex: 4,
            child: Center(
              child: asyncMovies.when(
                data: (data) => data.content.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Nessun file M3U caricato',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      )
                    : MovieGrid(list: data),
                error: (error, stackTrace) => Text(error.toString()),
                loading: () => Skeletonizer(
                  enabled: true,
                  child: MovieGrid(list: MediaContentList.fake()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieGrid extends ConsumerStatefulWidget {
  final MediaContentList list;

  const MovieGrid({super.key, required this.list});

  @override
  ConsumerState<MovieGrid> createState() => _MovieGridState();
}

class _MovieGridState extends ConsumerState<MovieGrid> {
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
    bool isHovered = false;
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
      itemCount: paginatedList.content.length,
      itemBuilder: (context, index) {
        final movie = widget.list.content[index];
        final imdbMetadataAsync = ref.watch(
          imdbMetadataProvider(movie.cleanTitle),
        );
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedScale(
            scale: (isHovered) ? 1.05 : 1,
            duration: const Duration(milliseconds: 200),
            child: imdbMetadataAsync.when(
              data: (data) {
                return MovieCard(
                  movie: movie,
                  onTap: () {
                    ref
                        .read(selectedMediaContentProvider.notifier)
                        .update(movie);
                    context.push('/player', extra: movie);
                  },
                );
              },
              error: (error, stackTrace) {
                return SizedBox.shrink();
              },
              loading: () {
                return Skeletonizer(
                  enabled: true,
                  child: MovieCard(movie: movie, onTap: () {}),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
