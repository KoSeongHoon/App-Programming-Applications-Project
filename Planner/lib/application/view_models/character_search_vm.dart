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
      await _repository.saveCharacter(character);
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
