import 'package:flutter/material.dart';
import '../../domain/entities/content_timeline.dart';
import '../theme/app_theme.dart';

class ContentStatusWidget extends StatelessWidget {
  final ContentTimeline contentTimeline;

  const ContentStatusWidget({
    Key? key,
    required this.contentTimeline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dungeonCount =
        contentTimeline.dungeons.where((d) => d.cleared).length;
    final legionCount =
        contentTimeline.legions.where((l) => l.cleared).length;
    final raidCount = contentTimeline.raids
        .where((r) => r.normalCleared || r.hardCleared)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '이 주의 과제',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _buildContentSection(
          context,
          '📋 상급던전',
          '$dungeonCount/${contentTimeline.dungeons.length}',
          contentTimeline.dungeons,
        ),
        _buildContentSection(
          context,
          '🏰 레기온',
          '${legionCount}/${contentTimeline.legions.length}',
          contentTimeline.legions,
        ),
        _buildRaidSection(context, contentTimeline.raids),
      ],
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    String title,
    String count,
    List items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final cleared = (item is DungeonClear || item is LegionClear)
                  ? (item as dynamic).cleared
                  : false;

              final name =
                  (item is DungeonClear || item is LegionClear)
                      ? (item as dynamic).name
                      : '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      cleared ? '✅' : '❌',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: cleared
                              ? AppTheme.textColor
                              : AppTheme.lightTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRaidSection(BuildContext context, List<RaidClear> raids) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚔️ 레이드',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${raids.where((r) => r.normalCleared || r.hardCleared).length}/${raids.length * 2}',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...raids.map((raid) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      raid.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Row(
                        children: [
                          _buildRaidDifficultyBadge(
                            '노말',
                            raid.normalCleared,
                          ),
                          const SizedBox(width: 8),
                          _buildRaidDifficultyBadge(
                            '하드',
                            raid.hardCleared,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRaidDifficultyBadge(String label, bool cleared) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cleared
            ? AppTheme.accentColor.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${cleared ? '✅' : '❌'} $label',
        style: TextStyle(
          fontSize: 11,
          color: cleared ? AppTheme.accentColor : AppTheme.lightTextColor,
        ),
      ),
    );
  }
}
