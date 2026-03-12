import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilePath = ref.watch(pathProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selected M3U File'),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      prefixIcon: IconButton(
                        icon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.folder),
                        ),
                        onPressed: () {},
                      ),
                      suffix: ShadButton(
                        backgroundColor: Colors.amber,
                        decoration: ShadDecoration(
                          border: ShadBorder.all(
                            radius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Change'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: context.colorScheme.secondary,
                        ),
                      ),
                    ),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(text: selectedFilePath ?? ''),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [Text('Theme'), Text('Light/Dark')],
            ),
          ],
        ),
      ),
    );
  }
}
