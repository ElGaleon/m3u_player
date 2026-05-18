import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:m3u_player/routing/routes.dart';
import 'package:m3u_player/services/providers/theme_provider.dart';
import 'package:m3u_player/theme.dart';
import 'package:media_kit/media_kit.dart' hide Media;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return ShadApp.router(
      title: 'M3U Player',
      theme: lightThemeData,
      routerConfig: router,
      darkTheme: darkThemeData,
      themeMode: themeMode,
    );
  }
}
