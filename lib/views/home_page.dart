import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/model/media_content_type.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          spacing: 16,
          children: MediaContentType.values
              .where((t) => t != MediaContentType.unknown)
              .map(
                (type) => InkWell(
                  child: ShadCard(title: Text(type.name)),
                  onTap: () {
                    ref.read(selectedMediaTypeProvider.notifier).update(type);
                    context.push('/${type.name}');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
