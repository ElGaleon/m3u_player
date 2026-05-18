import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/main.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the main media sections', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('M3U Player'), findsOneWidget);
    expect(find.text('Live Channels'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget);
  });
}
