import 'package:riverpod/riverpod.dart';

class FileFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> update(String filter) async {
    state = filter;
  }

  Future<void> clearFilter() async {
    state = null;
  }
}

final fileFilterProvider = NotifierProvider<FileFilterNotifier, String?>(
  () => FileFilterNotifier(),
);
