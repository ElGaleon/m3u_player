import 'package:go_router/go_router.dart';
import 'package:m3u_player/model/media_content.dart';
import 'package:m3u_player/views/home_page.dart';
import 'package:m3u_player/views/live_view.dart';
import 'package:m3u_player/views/movie_view.dart';
import 'package:m3u_player/views/series_details_view.dart';
import 'package:m3u_player/views/series_view.dart';

import '../views/video_player_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'M3U Player'),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final content = state.extra as MediaContent;
        return VideoPlayerPage(channel: content);
      },
    ),
    GoRoute(path: '/live', builder: (context, state) => const LiveView()),
    GoRoute(path: '/movie', builder: (context, state) => const MovieView()),
    GoRoute(path: '/series', builder: (context, state) => const SeriesView()),
    GoRoute(
      path: '/series-details',
      builder: (context, state) => const SeriesDetailScreen(),
    ),
  ],
);
