class ContentTimeline {
  // 상급던전
  final List<DungeonClear> dungeons;
  
  // 레기온
  final List<LegionClear> legions;
  
  // 레이드
  final List<RaidClear> raids;

  const ContentTimeline({
    this.dungeons = const [],
    this.legions = const [],
    this.raids = const [],
  });
}

// 상급던전 클리어 기록
class DungeonClear {
  final String name; // 던전 이름
  final bool cleared; // 클리어 여부
  final DateTime? clearedDate; // 클리어 날짜
  final String? difficulty; // 난이도

  const DungeonClear({
    required this.name,
    required this.cleared,
    this.clearedDate,
    this.difficulty,
  });
}

// 레기온 클리어 기록
class LegionClear {
  final String name; // 레기온 이름
  final bool cleared; // 클리어 여부
  final DateTime? clearedDate; // 클리어 날짜

  const LegionClear({
    required this.name,
    required this.cleared,
    this.clearedDate,
  });
}

// 레이드 클리어 기록
class RaidClear {
  final String name; // 레이드 이름
  final bool normalCleared; // 노말 클리어
  final bool hardCleared; // 하드 클리어
  final DateTime? normalClearedDate; // 노말 클리어 날짜
  final DateTime? hardClearedDate; // 하드 클리어 날짜

  const RaidClear({
    required this.name,
    required this.normalCleared,
    required this.hardCleared,
    this.normalClearedDate,
    this.hardClearedDate,
  });
}
