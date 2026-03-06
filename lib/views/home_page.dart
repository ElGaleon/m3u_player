import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../model/media_content_type.dart';
import '../services/providers/media_content_provider.dart';

class HomePage extends ConsumerWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                spacing: 16,
                children: MediaContentType.values
                    .where((t) => t != MediaContentType.unknown)
                    .map((type) {
                      final asyncMediaContentByType = ref.watch(
                        asyncMediaContentByTypeProvider(type),
                      );
                      return asyncMediaContentByType.when(
                        data: (data) {
                          return MediaContentCard(
                            type: type,
                            length: data.length,
                          );
                        },
                        error: (error, stackTrace) {
                          return SizedBox.shrink();
                        },
                        loading: () {
                          return Skeletonizer(
                            enabled: true,
                            child: MediaContentCard(type: type),
                          );
                        },
                      );
                    })
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Made with ❤️ by Christian Galeone'),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaContentCard extends ConsumerStatefulWidget {
  final MediaContentType type;
  final int? length;

  const MediaContentCard({super.key, required this.type, this.length});

  @override
  ConsumerState<MediaContentCard> createState() => _MediaContentCardState();
}

class _MediaContentCardState extends ConsumerState<MediaContentCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: (isHovered) ? 1.05 : 1,
            child: InkWell(
              child: ShadCard(
                columnCrossAxisAlignment: CrossAxisAlignment.center,
                columnMainAxisAlignment: MainAxisAlignment.center,
                columnMainAxisSize: MainAxisSize.max,
                title: Center(
                  child: Text(
                    widget.type.name.toUpperCase(),
                    style: TextStyle(
                      color: widget.type.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                width: context.mediaQuery.size.width * 0.25,
                border: ShadBorder.all(
                  color: (isHovered)
                      ? widget.type.color.withValues(alpha: 0.5)
                      : Colors.white12,
                  width: 2,
                ),
                height: context.mediaQuery.size.height * 0.35,
                footer: (widget.length != null)
                    ? ShadBadge(
                        backgroundColor: widget.type.color,
                        hoverBackgroundColor: widget.type.color,
                        child: Text(
                          '${widget.length} ${widget.type.label}',
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    : null,
                shadows: [
                  if (isHovered)
                    BoxShadow(
                      color: widget.type.color.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                ],
                child: SizedBox(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.type.color.withValues(
                            alpha: (isHovered) ? 0.3 : 0.15,
                          ),
                          blurRadius: 96,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.type.icon,
                      color: widget.type.color,
                      size: 200,
                    ),
                  ),
                ),
              ),
              onTap: () {
                ref
                    .read(selectedMediaTypeProvider.notifier)
                    .update(widget.type);
                context.push('/${widget.type.name}');
              },
            ),
          ),
        );
      },
    );
  }
}
