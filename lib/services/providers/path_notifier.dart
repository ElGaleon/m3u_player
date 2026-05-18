import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class PathNotifier extends Notifier<String?> {
  late final SharedPreferences _preferences;
  static const _key = "m3u_path";

  @override
  String? build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return _preferences.getString(_key);
  }

  Future<void> updatePath(String path) async {
    state = path;
    await _preferences.setString(_key, path);
  }

  Future<void> clearPath() async {
    state = null;
    await _preferences.remove(_key);
  }
}

final pathProvider = NotifierProvider<PathNotifier, String?>(() {
  return PathNotifier();
});
