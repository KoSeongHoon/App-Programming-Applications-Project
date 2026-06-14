import 'package:riverpod/riverpod.dart';
import '../../domain/entities/character.dart';
import '../../data/repositories/character_repository.dart';

class CharacterSearchState {
  final List<Character> searchResults; // 여러 캐릭터 저장
  final bool isLoading;
  final String? errorMessage;

  CharacterSearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CharacterSearchState copyWith({
    List<Character>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CharacterSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CharacterSearchViewModel extends StateNotifier<CharacterSearchState> {
  final CharacterRepository _repository;

  CharacterSearchViewModel(this._repository)
      : super(CharacterSearchState());

  Future<void> searchCharacter(
    String name,
    String server, {
    bool isGuildSearch = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final characters = await _repository.searchCharacter(
        name,
        server,
        isGuildSearch: isGuildSearch,
      );
      if (characters.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '검색 결과가 없습니다.',
        );
      } else {
        state = state.copyWith(
          searchResults: characters,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '오류가 발생했습니다: $e',
      );
    }
  }

  Future<void> saveCharacterToPlanner(Character character) async {
    try {
      // adventureName이 없으면 API에서 조회
      Character characterToSave = character;

      if (character.adventureName == null || character.adventureName!.isEmpty) {
        // API에서 캐릭터 기본정보 조회 (adventureName 포함)
        final info = await _repository.getCharacterInfo(
          character.characterId,
          character.serverId,
        );

        if (info != null) {
          // 기본정보가 있으면 adventureName 포함시켜 새로운 Character 생성
          characterToSave = Character(
            id: character.id,
            characterId: character.characterId,
            name: character.name,
            server: character.server,
            serverId: character.serverId,
            class_: character.class_,
            level: character.level,
            imageUrl: character.imageUrl,
            createdAt: character.createdAt,
            adventureName: info['adventureName'] as String?,
            timeline: character.timeline,
          );
        }
      }

      // Character 저장
      await _repository.saveCharacter(characterToSave);

      // PlannerItem에도 추가 ✅
      await _repository.addCharacterToPlanner(character.characterId);
    } catch (e) {
      rethrow;
    }
  }

  void clearSelection() {
    state = CharacterSearchState();
  }
}

final characterSearchViewModelProvider =
    StateNotifierProvider<CharacterSearchViewModel, CharacterSearchState>((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return CharacterSearchViewModel(repository);
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl();
});
