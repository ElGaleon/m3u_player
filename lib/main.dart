import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/providers/path_notifier.dart';
import 'package:m3u_player/views/home_page.dart';
import 'package:m3u_player/views/video_player_page.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/channel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const MyHomePage(title: 'M3U Editor'),
          );
        }
        if (settings.name == '/player') {
          final args = settings.arguments as Channel;
          return MaterialPageRoute(
            builder: (_) => VideoPlayerPage(channel: args),
          );
        }
      },
    );
  }
}
