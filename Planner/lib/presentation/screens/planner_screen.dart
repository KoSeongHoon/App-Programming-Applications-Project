import 'package:flutter/material.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // 더미 데이터
  final List<Map<String, dynamic>> characters = [
    {
      'name': '고성훈',
      'class': '검술사',
      'level': 110,
      'server': '온라인 1서',
    },
  ];

  final List<Map<String, dynamic>> plannerItems = [
    {
      'name': '상급던전',
      'completed': false,
      'difficulty': '상급',
    },
    {
      'name': '프래그만 던전',
      'completed': true,
      'difficulty': '일반',
    },
    {
      'name': '마계 협곡',
      'completed': false,
      'difficulty': '상급',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('플래너'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: '콘텐츠 추가',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // 탭 바
            TabBar(
              indicatorColor: Colors.blue[700],
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '캐릭터'),
                Tab(text: '콘텐츠'),
              ],
            ),
            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                children: [
                  // 캐릭터 탭
                  _buildCharacterTab(),
                  // 콘텐츠 탭
                  _buildContentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return _CharacterCard(
          name: character['name'],
          class_: character['class'],
          level: character['level'],
          server: character['server'],
        );
      },
    );
  }

  Widget _buildContentTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plannerItems.length,
      itemBuilder: (context, index) {
        final item = plannerItems[index];
        return _PlannerItemCard(
          name: item['name'],
          completed: item['completed'],
          difficulty: item['difficulty'],
          onChanged: (value) {
            setState(() {
              plannerItems[index]['completed'] = value;
            });
          },
        );
      },
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String name;
  final String class_;
  final int level;
  final String server;

  const _CharacterCard({
    required this.name,
    required this.class_,
    required this.level,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        class_,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Lv. $level',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  server,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerItemCard extends StatelessWidget {
  final String name;
  final bool completed;
  final String difficulty;
  final Function(bool) onChanged;

  const _PlannerItemCard({
    required this.name,
    required this.completed,
    required this.difficulty,
    required this.onChanged,
  });

  Color _getDifficultyColor() {
    switch (difficulty) {
      case '상급':
        return Colors.red;
      case '중급':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: completed,
          onChanged: (value) => onChanged(value ?? false),
          checkColor: Colors.white,
          activeColor: Colors.green,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? Colors.grey : Colors.black,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getDifficultyColor(),
            ),
          ),
        ),
      ),
    );
  }
}
