import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../popular/presentation/pages/popular_page.dart';
import '../../../routes/presentation/pages/routes_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/app_drawer.dart';

/// Current tab index provider
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Global key for scaffold to access drawer from child pages
final scaffoldKey = GlobalKey<ScaffoldState>();

/// Main page with bottom navigation - Premium design with SVG icons
class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final pages = [
      const MapPage(),
      const PopularPage(),
      const RoutesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: _TravelyBottomNavBar(
        currentIndex: currentTab,
        onTap: (index) => ref.read(currentTabProvider.notifier).state = index,
      ),
    );
  }
}

/// Premium Bottom Navigation Bar with SVG icons - matches Figma design
class _TravelyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _TravelyBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Same color as input/text field background for consistency
        color: AppColors.inputBackgroundLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                selectedIcon: 'assets/images/selected/map_marker.svg',
                unselectedIcon: 'assets/images/unselected/map_marker.svg',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                selectedIcon: 'assets/images/selected/fire_flame_curved.svg',
                unselectedIcon:
                    'assets/images/unselected/fire_flame_curved.svg',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                selectedIcon: 'assets/images/selected/time_past.svg',
                unselectedIcon: 'assets/images/unselected/time_past.svg',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                selectedIcon: 'assets/images/selected/circle_user.svg',
                unselectedIcon: 'assets/images/unselected/circle_user.svg',
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

/// Single navigation item with fixed 24x24 SVG icon and selection state
class _NavItem extends StatelessWidget {
  final String selectedIcon;
  final String unselectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? AppColors.white : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            // Fixed size SvgPicture with explicit width/height
            child: SvgPicture.asset(
              isSelected ? selectedIcon : unselectedIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              // Apply color filter for consistent rendering
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : AppColors.textHint,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
