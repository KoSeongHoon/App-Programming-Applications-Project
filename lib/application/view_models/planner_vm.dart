import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/content_timeline.dart';
import '../../data/repositories/character_repository.dart';

class PlannerState {
  final List<Character> characters;
  final bool isLoading;
  final Map<String, ContentTimeline> contentTimelines; // 캐릭터별 컨텐츠 타임라인

  const PlannerState({
    this.characters = const [],
    this.isLoading = false,
    this.contentTimelines = const {},
  });

  PlannerState copyWith({
    List<Character>? characters,
    bool? isLoading,
    Map<String, ContentTimeline>? contentTimelines,
  }) {
    return PlannerState(
      characters: characters ?? this.characters,
      isLoading: isLoading ?? this.isLoading,
      contentTimelines: contentTimelines ?? this.contentTimelines,
    );
  }
}

class PlannerViewModel extends StateNotifier<PlannerState> {
  final CharacterRepository _repository;

  PlannerViewModel(this._repository) : super(const PlannerState()) {
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    state = state.copyWith(isLoading: true);
    try {
      final characters = await _repository.getAllCharacters();

      // 각 캐릭터의 컨텐츠 타임라인 로드
      final timelines = <String, ContentTimeline>{};
      for (final character in characters) {
        try {
          final timeline =
              await _repository.parseContentTimeline(character);
          timelines[character.characterId] = timeline;
        } catch (e) {
          // 타임라인 로드 실패 시 빈 timeline 할당
          timelines[character.characterId] = ContentTimeline();
        }
      }

      state = state.copyWith(
        characters: characters,
        contentTimelines: timelines,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteCharacter(String characterId) async {
    try {
      await _repository.deleteCharacter(characterId);
      final updated = state.characters
          .where((c) => c.characterId != characterId)
          .toList();
      state = state.copyWith(characters: updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshCharacters() async {
    await _loadCharacters();
  }

  // 특정 캐릭터의 컨텐츠 타임라인 재검색
  Future<void> refreshContentTimeline(Character character) async {
    try {
      final timeline = await _repository.parseContentTimeline(character);
      final timelines = Map<String, ContentTimeline>.from(state.contentTimelines);
      timelines[character.characterId] = timeline;
      state = state.copyWith(contentTimelines: timelines);
    } catch (e) {
      // 실패 시 빈 timeline 할당
      final timelines = Map<String, ContentTimeline>.from(state.contentTimelines);
      timelines[character.characterId] = ContentTimeline();
      state = state.copyWith(contentTimelines: timelines);
    }
  }
}

final plannerViewModelProvider =
    StateNotifierProvider<PlannerViewModel, PlannerState>((ref) {
  return PlannerViewModel(CharacterRepositoryImpl());
});
