import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/extensions/build_context_extensions.dart';
import 'package:m3u_player/model/group_category.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../services/providers/file_filter_provider.dart';
import '../services/providers/media_content_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroupCategory = ref.watch(asyncGroupedCategoryProvider);
    return asyncGroupCategory.when(
      data: (groupCategoryMap) {
        return SidebarContent(content: groupCategoryMap);
      },
      loading: () => Center(
        child: Skeletonizer(
          enabled: true,
          child: SidebarContent(content: GroupedCategoryMap.fake()),
        ),
      ),
      error: (e, _) => const Icon(Icons.error),
    );
  }
}

class SidebarContent extends ConsumerWidget {
  final GroupedCategoryMap content;
  const SidebarContent({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(fileFilterProvider);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      itemCount: content.value.keys.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final GroupCategory groupCategory = content.value.keys.elementAt(index);
        final List<String>? itemsInCategory = content.value[groupCategory];
        if (itemsInCategory?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            _SidebarGroupHeader(label: groupCategory.label),
            ...itemsInCategory!.map(
              (item) => _SidebarItem(
                label: item,
                isSelected: currentFilter == item,
                onTap: () {
                  final notifier = ref.read(fileFilterProvider.notifier);
                  currentFilter == item
                      ? notifier.clearFilter()
                      : notifier.update(item);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final bgColor = isSelected ? theme.colorScheme.accent : Colors.transparent;

    final textColor = isSelected
        ? theme.colorScheme.accentForeground
        : theme.colorScheme.foreground.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: theme.colorScheme.accent.withValues(alpha: 0.5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.small.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarGroupHeader extends StatelessWidget {
  final String label;
  const _SidebarGroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        label,
        style: context.textTheme.muted.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
