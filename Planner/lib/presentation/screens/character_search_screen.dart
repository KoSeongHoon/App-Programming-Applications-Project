import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../application/view_models/character_search_vm.dart';
import '../../domain/entities/character.dart';

class CharacterSearchScreen extends ConsumerStatefulWidget {
  const CharacterSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharacterSearchScreen> createState() =>
      _CharacterSearchScreenState();
}

class _CharacterSearchScreenState extends ConsumerState<CharacterSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = '전체'; // 통합 필터

  final List<String> filterOptions = [
    '전체',
    '모험단',
    '카인',
    '디레지에',
    '시로코',
    '프레이',
    '카시야스',
    '힐더',
    '안튼',
    '바칼',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(characterSearchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 검색'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 검색창 및 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // 통합 필터 드롭다운
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          underline: const SizedBox(),
                          items: filterOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedFilter = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 검색창
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: _selectedFilter == '모험단'
                                ? '모험단명 입력'
                                : '캐릭터명 입력',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _search(ref),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: searchState.isLoading ? null : () => _search(ref),
                      icon: searchState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        searchState.isLoading ? '검색중...' : '검색',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 에러 메시지
            if (searchState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    searchState.errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ),

            // 검색 결과
            Expanded(
              child: searchState.searchResults.isNotEmpty
                  ? _buildSearchResultList(searchState.searchResults)
                  : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultList(List<Character> characters) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '검색 결과: ${characters.length}개',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ...characters
              .map((character) => Column(
                    children: [
                      _buildSearchResult(character),
                      const SizedBox(height: 16),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSearchResult(Character character) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 캐릭터 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              character.imageUrl,
              width: 150,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 서버명
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 캐릭터 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                character.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                character.class_,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lv. ${character.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 추가 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('캐릭터가 플래너에 추가되었습니다'),
                  ),
                );
              },
              child: const Text('플래너에 추가'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              '캐릭터를 검색하세요',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _search(WidgetRef ref) {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('검색어를 입력하세요'),
        ),
      );
      return;
    }

    // 필터에 따라 검색 타입 결정
    final isGuildSearch = _selectedFilter == '모험단';
    final server = '전체';

    ref
        .read(characterSearchViewModelProvider.notifier)
        .searchCharacter(query, server, isGuildSearch: isGuildSearch);
  }
}

