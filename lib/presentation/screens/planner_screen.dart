import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../application/view_models/planner_vm.dart';
import '../../domain/entities/content_timeline.dart';
import '../../domain/utils/content_utils.dart';
import 'content_status_widget.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(plannerViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  // 제목과 조회 날짜 범위
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '캐릭터 플래너',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '관리 중: ${plannerState.characters.length}개',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      // 조회 시작 날짜 (상단 오른쪽)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '조회 시작',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStartDateString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (plannerState.characters.isEmpty)
              Expanded(
                child: Center(
                  child: Text('추가된 캐릭터가 없습니다'),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // 각 캐릭터별 정보 + 컨텐츠 상태 표시
                        ...plannerState.characters.map((character) {
                          final contentTimeline = plannerState
                                  .contentTimelines[character.characterId] ??
                              ContentTimeline();

                          return Column(
                            children: [
                              _buildCharacterCard(context, ref, character),
                              const SizedBox(height: 12),
                              // 컨텐츠 헤더 + 재검색 버튼
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '주간 컨텐츠',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      ref
                                          .read(plannerViewModelProvider.notifier)
                                          .refreshContentTimeline(character);
                                    },
                                    tooltip: '클리어 기록 새로고침',
                                  ),
                                ],
                              ),
                              ContentStatusWidget(
                                contentTimeline: contentTimeline,
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, WidgetRef ref, dynamic character) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.network(
            character.imageUrl,
            width: 80,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 100,
                color: AppTheme.borderColor,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(character.class_),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        character.server,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Lv. ${character.level}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[400],
            onPressed: () {
              ref
                  .read(plannerViewModelProvider.notifier)
                  .deleteCharacter(character.characterId);
            },
          ),
        ],
      ),
    );
  }

  /// 조회 시작 날짜를 포맷팅하는 메서드
  String _getStartDateString() {
    final now = DateTime.now();
    final daysToLastThursday = now.weekday > 4 ? now.weekday - 4 : now.weekday + 3;
    final startDate = now.subtract(Duration(days: daysToLastThursday));

    return '${startDate.month}/${startDate.day} (${_getDayName(startDate)})';
  }

  /// 요일 이름 반환
  String _getDayName(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }
}
