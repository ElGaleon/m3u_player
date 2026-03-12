import 'package:go_router/go_router.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/views/cinema_view.dart';
import 'package:m3u_player/views/home_page.dart';
import 'package:m3u_player/views/live_view.dart';
import 'package:m3u_player/views/series_details_view.dart';
import 'package:m3u_player/views/settings_view.dart';
import 'package:m3u_player/views/video_player_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(title: 'M3U Player'),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final media = state.extra as PlayableEntity;
        return VideoPlayerPage(media: media);
      },
    ),
    GoRoute(path: '/live', builder: (context, state) => const LiveView()),
    GoRoute(path: '/movie', builder: (context, state) => const CinemaView()),
    GoRoute(path: '/series', builder: (context, state) => const CinemaView()),
    GoRoute(
      path: '/series-details',
      builder: (context, state) => const SeriesDetailScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
);
