class Character {
  final int id;
  final String characterId;
  final String name;
  final String server;
  final String class_;
  final int level;
  final DateTime createdAt;

  Character({
    required this.id,
    required this.characterId,
    required this.name,
    required this.server,
    required this.class_,
    required this.level,
    required this.createdAt,
  });

  bool isHighLevel() => level >= 50;

  String displayName() => '$name ($server)';

  @override
  String toString() => 'Character(id: $id, name: $name, level: $level)';
}
