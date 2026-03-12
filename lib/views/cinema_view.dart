import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/components/sidebar.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/model/media_entity.dart';
import 'package:m3u_player/services/providers/file_filter_provider.dart';
import 'package:m3u_player/services/providers/selected_media_content_provider.dart';
import 'package:m3u_player/views/components/cinema_grid.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/providers/media_content_provider.dart';

class CinemaView extends ConsumerWidget {
  const CinemaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMediaEntityList = ref.watch(filteredMediaProvider);
    final searchTerm = ref.watch(searchMediaContentProvider);
    final searchTermNotifier = ref.watch(searchMediaContentProvider.notifier);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, value) {
        ref.invalidate(selectedMediaTypeProvider);
        ref.invalidate(selectedMediaEntityProvider);
        ref.invalidate(fileFilterProvider);
        ref.invalidate(filteredMediaProvider);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 96,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SearchBar(
              controller: TextEditingController(
                text: searchTerm,
              )..selection = TextSelection.collapsed(offset: searchTerm.length),
              leading: Icon(Icons.search),
              trailing: [
                if (searchTerm.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      (searchTerm.isNotEmpty)
                          ? searchTermNotifier.state = ''
                          : null;
                    },
                  ),
              ],
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(color: context.colorScheme.secondary),
                  borderRadius: BorderRadiusGeometry.circular(16),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (value) {
                searchTermNotifier.state = value;
              },
            ),
          ),
        ),
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 300, child: Sidebar()),
            Expanded(
              flex: 4,
              child: Center(
                child: asyncMediaEntityList.when(
                  data: (data) => data.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No $selectedMediaTypeProvider found with these parameters',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        )
                      : CinemaGrid(list: data),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: CinemaGrid(list: fakeCatalog),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
