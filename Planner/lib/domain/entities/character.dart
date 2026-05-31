class Character {
  final int id;
  final String characterId;
  final String name;
  final String server;
  final String serverId; // 서버 ID (API 응답용)
  final String class_;
  final int level;
  final String imageUrl; // 캐릭터 이미지 URL
  final DateTime createdAt;

  // 모험단 정보 (향후 컨텐츠 플래너용)
  final String? adventureName; // 모험단명
  final List<Map<String, dynamic>> timeline; // 타임라인 데이터 (클리어 기록 등)

  Character({
    required this.id,
    required this.characterId,
    required this.name,
    required this.server,
    required this.serverId,
    required this.class_,
    required this.level,
    required this.imageUrl,
    required this.createdAt,
    this.adventureName,
    this.timeline = const [],
  });

  bool isHighLevel() => level >= 50;

  String displayName() => '$name ($server)';

  @override
  String toString() => 'Character(id: $id, name: $name, level: $level)';
}
