import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' show GoRouterHelper;
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/model/media_content_type.dart';
import 'package:m3u_player/services/providers/media_content_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final size = context.mediaQuery.size;
    final isCompact = size.width < 760;
    final cardWidth = isCompact ? double.infinity : size.width * 0.25;
    final cardHeight = isCompact ? 172.0 : size.height * 0.35;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        scale: (isHovered) ? 1.05 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(selectedMediaTypeProvider.notifier).update(widget.type);
            context.push('/${widget.type.name}');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colorScheme.card,
              border: Border.all(
                color: isHovered
                    ? widget.type.color.withValues(alpha: 0.5)
                    : context.colorScheme.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: widget.type.color.withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  widget.type.label,
                  style:
                      (isCompact ? context.textTheme.h3 : context.textTheme.h2)
                          .copyWith(
                            color: widget.type.color,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isHovered)
                          BoxShadow(
                            color: widget.type.color.withValues(alpha: 0.3),
                            blurRadius: 96,
                            spreadRadius: 6,
                          ),
                      ],
                    ),
                    child: FittedBox(
                      child: Icon(widget.type.icon, color: widget.type.color),
                    ),
                  ),
                ),
                if (widget.length != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShadBadge(
                      backgroundColor: widget.type.color,
                      hoverBackgroundColor: widget.type.color,
                      child: Text(
                        '${widget.length} ${widget.type.label}',
                        style: context.textTheme.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
