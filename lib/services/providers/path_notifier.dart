import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class PathNotifier extends StateNotifier<String?> {
  final SharedPreferences _preferences;
  static const _key = "m3u_path";

  PathNotifier(this._preferences) : super(_preferences.getString(_key));

  Future<void> updatePath(String path) async {
    state = path;
    await _preferences.setString(_key, path);
  }

  Future<void> clearPath() async {
    state = null;
    await _preferences.remove(_key);
  }
}

final pathProvider = StateNotifierProvider<PathNotifier, String?>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return PathNotifier(preferences);
});
