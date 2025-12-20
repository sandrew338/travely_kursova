import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../popular/presentation/pages/popular_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/app_drawer.dart';

/// Current tab index provider
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Main page with bottom navigation - Figma Design (4 tabs)
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final pages = [
      const MapPage(),
      const PopularPage(),
      const RoutesPage(), // History page
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentTab,
        onTap: (index) => ref.read(currentTabProvider.notifier).state = index,
      ),
    );
  }
}

/// Custom Bottom Navigation Bar - matches Figma design exactly
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Map icon
              _NavIcon(
                icon: _MapIcon(isActive: currentIndex == 0),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              // Fire/Popular icon
              _NavIcon(
                icon: _FireIcon(isActive: currentIndex == 1),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // History icon
              _NavIcon(
                icon: _HistoryIcon(isActive: currentIndex == 2),
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              // Profile icon
              _NavIcon(
                icon: _ProfileIcon(isActive: currentIndex == 3),
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.surfaceVariant : Colors.transparent,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

/// Map icon - location marker style
class _MapIcon extends StatelessWidget {
  final bool isActive;
  const _MapIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on_outlined,
      size: 28,
      color: isActive ? AppColors.textPrimary : AppColors.textHint,
    );
  }
}

/// Fire icon - for Popular/Trending
class _FireIcon extends StatelessWidget {
  final bool isActive;
  const _FireIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.local_fire_department_outlined,
      size: 28,
      color: isActive ? AppColors.textPrimary : AppColors.textHint,
    );
  }
}

/// History icon - clock/time
class _HistoryIcon extends StatelessWidget {
  final bool isActive;
  const _HistoryIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.history,
      size: 28,
      color: isActive ? AppColors.textPrimary : AppColors.textHint,
    );
  }
}

/// Profile icon - user circle
class _ProfileIcon extends StatelessWidget {
  final bool isActive;
  const _ProfileIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.account_circle_outlined,
      size: 28,
      color: isActive ? AppColors.textPrimary : AppColors.textHint,
    );
  }
}
