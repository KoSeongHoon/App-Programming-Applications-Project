import 'package:riverpod/riverpod.dart';
import '../../domain/entities/character.dart';
import '../../data/repositories/character_repository.dart';

class CharacterSearchState {
  final Character? selectedCharacter;
  final bool isLoading;
  final String? errorMessage;

  CharacterSearchState({
    this.selectedCharacter,
    this.isLoading = false,
    this.errorMessage,
  });

  CharacterSearchState copyWith({
    Character? selectedCharacter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CharacterSearchState(
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CharacterSearchViewModel extends StateNotifier<CharacterSearchState> {
  final CharacterRepository _repository;

  CharacterSearchViewModel(this._repository)
      : super(CharacterSearchState());

  Future<void> searchCharacter(String name, String server) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final character = await _repository.searchCharacter(name, server);
      if (character == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '캐릭터를 찾을 수 없습니다.',
        );
      } else {
        state = state.copyWith(
          selectedCharacter: character,
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
