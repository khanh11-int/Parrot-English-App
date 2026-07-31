import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Vỏ chứa 4 tab gốc: giữ thanh điều hướng dưới cố định, phần thân đổi theo tab.
///
/// Dùng [StatefulNavigationShell] nên mỗi tab giữ được vị trí cuộn và lịch sử
/// điều hướng riêng khi người dùng chuyển qua lại.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: navigationShell,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        // `initialLocation: true` khi bấm lại tab đang mở → quay về đầu tab đó,
        // giống hành vi quen thuộc của các app tab-based.
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
