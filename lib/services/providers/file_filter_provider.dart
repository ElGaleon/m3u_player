import 'package:flutter_riverpod/legacy.dart';

class FileFilterNotifier extends StateNotifier<String?> {
  FileFilterNotifier(super.state);

  Future<void> update(String filter) async {
    state = filter;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final fileFilterProvider = StateNotifierProvider<FileFilterNotifier, String?>(
  (ref) => FileFilterNotifier(null),
);
