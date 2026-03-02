import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../model/group_category.dart';
import '../providers/file_controller.dart';
import '../providers/file_filter_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(asyncGroupsProvider);
    final currentFilter = ref.watch(fileFilterProvider);
    final theme = ShadTheme.of(context);

    return asyncGroups.when(
      data: (rawList) {
        final Map<GroupCategory, List<String>> organized = {};

        for (var name in rawList) {
          final cat = GroupClassifier.classify(name);
          organized.putIfAbsent(cat, () => []).add(name);
        }

        final displayOrder = [
          GroupCategory.scopri,
          GroupCategory.genere,
          GroupCategory.piattaforma,
          GroupCategory.annata,
          GroupCategory.attore,
          GroupCategory.regista,
          GroupCategory.adult,
        ];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          itemCount: displayOrder.length,
          itemBuilder: (context, index) {
            final category = displayOrder[index];
            final items = organized[category] ?? [];

            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(category, theme),
                ...items.map(
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
                const SizedBox(height: 16), // Spazio tra sezioni
              ],
            );
          },
        );
      },
      loading: () => const Center(child: ShadProgress()),
      error: (e, _) => const Icon(Icons.error),
    );
  }

  Widget _buildHeader(GroupCategory cat, ShadThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        cat.label,
        style: theme.textTheme.muted.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
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
            // Indicatore fisso per evitare il layout shift
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
