/// 타임라인 컨텐츠 관련 유틸리티 함수
library;

/// 주간 범위 계산 (지난 목요일부터 다음 목요일까지)
/// 목요일은 동작 범위에 포함, 수요일 23:59:59까지 집계
Map<String, DateTime> calculateWeeklyRange(DateTime now) {
  // 오늘 요일 확인 (월=1, 일=7, 목=4)
  final weekday = now.weekday; // 1=Monday, 4=Thursday, 7=Sunday

  // 지난 목요일 계산
  late DateTime prevThursday;
  if (weekday >= 4) {
    // 목요일 이상: (weekday - 4)일 전 목요일
    prevThursday = now.subtract(Duration(days: weekday - 4));
  } else {
    // 목요일 미만 (월-수): 3일 + (4 - weekday)일 = (7 - weekday)일 전
    prevThursday = now.subtract(Duration(days: 7 - weekday + 4));
  }

  // 다음 목요일 계산 (지난 목요일 + 7일)
  final nextThursday = prevThursday.add(const Duration(days: 7));

  // 시간을 00:00:00으로 정규화 (날짜만 비교하기 쉽게)
  prevThursday = DateTime(prevThursday.year, prevThursday.month, prevThursday.day);
  final nextThursdayEnd = DateTime(nextThursday.year, nextThursday.month, nextThursday.day, 23, 59, 59);

  return {
    'start': prevThursday,
    'end': nextThursdayEnd,
  };
}

/// 상급던전 매핑
const Map<String, String> dungeonNameMap = {
  '최후의 과업': '최후의 과업',
  'Abyss Challenger': '최후의 과업',
  '배교자의 성': '배교자의 성',
  "Heretics' Sanctuary": '배교자의 성',
  '별거북 대서고': '별거북 대서고',
  'Shadowland Labyrinth': '별거북 대서고',
  '해방된 흉몽': '해방된 흉몽',
  'Liberated Nightmare': '해방된 흉몽',
  '죽음의 여신전': '죽음의 여신전',
  'Deathly Goddess': '죽음의 여신전',
  '에쥬어 메인': '에쥬어 메인',
  'Ezer Main': '에쥬어 메인',
  '달이 잠긴 호수': '달이 잠긴 호수',
  'Moonlit Lake': '달이 잠긴 호수',
};

/// 레기온 매핑
const Map<String, String> legionNameMap = {
  '아포칼립스': '아포칼립스',
  'Apocalypse': '아포칼립스',
  '아포칼립스 군단': '아포칼립스',
  'Apocalypse Legion': '아포칼립스',
  '미의 여신 베누스': '미의 여신 베누스',
  'Goddess Venus': '미의 여신 베누스',
  '비너스 군단': '미의 여신 베누스',
  'Venus Legion': '미의 여신 베누스',
};

/// 레이드 매핑
const Map<String, String> raidNameMap = {
  '디레지에 레이드': '디레지에 레이드',
  'Diregie Raid': '디레지에 레이드',
  '이내황혼전': '이내황혼전',
  'Twilight Darkness': '이내황혼전',
  '만들어진 신 나벨': '만들어진 신 나벨',
  'Nabel the Created': '만들어진 신 나벨',
};

/// API 응답의 raidName이 어느 컨텐츠에 해당하는지 매칭
String? matchDungeonName(String apiName) {
  return dungeonNameMap[apiName] ?? _fuzzyMatchName(apiName, dungeonNameMap.values.toList());
}

String? matchLegionName(String apiName) {
  return legionNameMap[apiName] ?? _fuzzyMatchName(apiName, legionNameMap.values.toList());
}

String? matchRaidName(String apiName) {
  return raidNameMap[apiName] ?? _fuzzyMatchName(apiName, raidNameMap.values.toList());
}

/// 퍼지 매칭 (부분 문자열 검사)
String? _fuzzyMatchName(String input, List<String> targets) {
  final lowerInput = input.toLowerCase();

  // 정확한 포함 관계 확인
  for (final target in targets) {
    if (lowerInput.contains(target.toLowerCase()) ||
        target.toLowerCase().contains(lowerInput)) {
      return target;
    }
  }

  return null;
}

/// 모든 상급던전 리스트 반환 (순서대로)
List<String> getAllDungeons() {
  return [
    '최후의 과업',
    '배교자의 성',
    '별거북 대서고',
    '해방된 흉몽',
    '죽음의 여신전',
    '에쥬어 메인',
    '달이 잠긴 호수',
  ];
}

/// 모든 레기온 리스트 반환
List<String> getAllLegions() {
  return [
    '아포칼립스',
    '미의 여신 베누스',
  ];
}

/// 모든 레이드 리스트 반환
List<String> getAllRaids() {
  return [
    '디레지에 레이드',
    '이내황혼전',
    '만들어진 신 나벨',
  ];
}
