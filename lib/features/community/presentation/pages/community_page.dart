import 'package:flutter/material.dart';

import '../widgets/leaderboard_tab.dart';
import '../widgets/study_group_tab.dart';

/// Tab Cộng đồng với 3 tab con — mục 5.6 của `docs/UI_SPEC.md`.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Trong suốt để thấy gradient nền của vỏ app.
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cộng đồng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Nhóm học tập'),
              Tab(text: 'Bảng xếp hạng'),
            ],
          ),
        ),
        body: const TabBarView(children: [StudyGroupTab(), LeaderboardTab()]),
      ),
    );
  }
}
