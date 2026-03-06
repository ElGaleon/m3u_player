import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../services/providers/media_content_provider.dart';
import '../services/providers/selected_media_content_provider.dart';

class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(selectedSeriesProvider);
    final selectedSeason = ref.watch(currentSeasonProvider);
    final theme = ShadTheme.of(context);

    if (series == null) {
      return const Scaffold(body: Center(child: Text("Errore")));
    }

    final seasonsList = series.seasons.keys.toList()..sort();
    final episodes = series.seasons[selectedSeason] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(series.cleanTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Stagioni disponibili:", style: theme.textTheme.p),
                ShadSelect<int>(
                  placeholder: const Text('Select a fruit'),
                  initialValue: selectedSeason,
                  options: [
                    ...seasonsList.map(
                      (e) => ShadOption(
                        value: e,
                        child: Text("Stagione ${e.toString()}"),
                      ),
                    ),
                  ],

                  selectedOptionBuilder: (context, value) =>
                      Text("Stagione ${value.toString()}"),
                  onChanged: (newSeason) {
                    if (newSeason != null) {
                      ref.read(currentSeasonProvider.notifier).state =
                          newSeason;
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // Lista Episodi
          Expanded(
            child: ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final ep = episodes[index];

                return ListTile(
                  leading: const Icon(Icons.play_arrow_rounded),
                  title: Text(
                    ep.name.split(RegExp(r'S\d+ E\d+')).last.trim().isEmpty
                        ? "Episodio ${index + 1}"
                        : ep.name,
                  ),
                  subtitle: Text("Premi per avviare la riproduzione"),
                  onTap: () {
                    ref.read(selectedMediaContentProvider.notifier).update(ep);
                    context.push('/player', extra: ep);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
