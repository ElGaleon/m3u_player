import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/services/providers/epg_provider.dart';
import 'package:m3u_player/services/providers/library_provider.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:m3u_player/services/providers/theme_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilePath = ref.watch(pathProvider);
    final epgPath = ref.watch(epgPathProvider);
    final themeMode = ref.watch(themeProvider);
    final library = ref.watch(libraryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 24,
                  children: [
                    _SettingsSection(
                      title: 'Playlist',
                      child: Flex(
                        direction: isCompact ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          _SettingsLabel(
                            width: isCompact ? double.infinity : 180,
                            label: 'Selected M3U file',
                          ),
                          if (isCompact)
                            SizedBox(
                              width: double.infinity,
                              child: _PlaylistPathField(
                                selectedFilePath: selectedFilePath,
                              ),
                            )
                          else
                            Expanded(
                              child: _PlaylistPathField(
                                selectedFilePath: selectedFilePath,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _SettingsSection(
                      title: 'Appearance',
                      child: Flex(
                        direction: isCompact ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          _SettingsLabel(
                            width: isCompact ? double.infinity : 180,
                            label: 'Theme',
                          ),
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto_outlined),
                                label: Text('System'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode_outlined),
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode_outlined),
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {themeMode},
                            onSelectionChanged: (selection) {
                              ref
                                  .read(themeProvider.notifier)
                                  .updateTheme(selection.first);
                            },
                          ),
                        ],
                      ),
                    ),
                    _SettingsSection(
                      title: 'EPG',
                      child: Flex(
                        direction: isCompact ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          _SettingsLabel(
                            width: isCompact ? double.infinity : 180,
                            label: 'XMLTV file',
                          ),
                          if (isCompact)
                            SizedBox(
                              width: double.infinity,
                              child: _EpgPathField(selectedPath: epgPath),
                            )
                          else
                            Expanded(
                              child: _EpgPathField(selectedPath: epgPath),
                            ),
                        ],
                      ),
                    ),
                    _SettingsSection(
                      title: 'Library',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ShadBadge(
                            child: Text(
                              '${library.favoriteKeys.length} favorites',
                            ),
                          ),
                          ShadBadge(
                            child: Text(
                              '${library.continueWatchingKeys.length} recent',
                            ),
                          ),
                          ShadButton.outline(
                            onPressed: library.favoriteKeys.isEmpty
                                ? null
                                : () => ref
                                      .read(libraryProvider.notifier)
                                      .clearFavorites(),
                            child: const Text('Clear favorites'),
                          ),
                          ShadButton.outline(
                            onPressed: library.continueWatchingKeys.isEmpty
                                ? null
                                : () => ref
                                      .read(libraryProvider.notifier)
                                      .clearContinueWatching(),
                            child: const Text('Clear recent'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlaylistPathField extends ConsumerWidget {
  final String? selectedFilePath;

  const _PlaylistPathField({required this.selectedFilePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.folder_outlined),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ShadButton(
            height: 36,
            backgroundColor: Colors.amber,
            decoration: ShadDecoration(
              border: ShadBorder.all(radius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['m3u', 'm3u8'],
              );
              final path = result?.files.single.path;
              if (path != null && path.isNotEmpty) {
                await ref.read(pathProvider.notifier).updatePath(path);
              }
            },
            child: const Text('Change'),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colorScheme.secondary),
        ),
      ),
      controller: TextEditingController.fromValue(
        TextEditingValue(text: selectedFilePath ?? ''),
      ),
    );
  }
}

class _EpgPathField extends ConsumerWidget {
  final String? selectedPath;

  const _EpgPathField({required this.selectedPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.calendar_month_outlined),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Wrap(
            spacing: 8,
            children: [
              if (selectedPath != null)
                ShadButton.outline(
                  height: 36,
                  onPressed: () =>
                      ref.read(epgPathProvider.notifier).clearPath(),
                  child: const Icon(Icons.close, size: 16),
                ),
              ShadButton(
                height: 36,
                backgroundColor: Colors.amber,
                decoration: ShadDecoration(
                  border: ShadBorder.all(radius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xml'],
                  );
                  final path = result?.files.single.path;
                  if (path != null && path.isNotEmpty) {
                    await ref.read(epgPathProvider.notifier).updatePath(path);
                  }
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.colorScheme.secondary),
        ),
      ),
      controller: TextEditingController.fromValue(
        TextEditingValue(text: selectedPath ?? ''),
      ),
    );
  }
}

class _SettingsLabel extends StatelessWidget {
  final double width;
  final String label;

  const _SettingsLabel({required this.width, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: context.textTheme.small.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(title, style: theme.textTheme.h4),
            child,
          ],
        ),
      ),
    );
  }
}
