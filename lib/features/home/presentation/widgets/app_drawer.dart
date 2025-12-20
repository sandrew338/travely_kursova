import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../pages/main_page.dart';

/// Side drawer menu - matches Figma design
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Travely Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Text(
                'Travely',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kanit',
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Menu Items
            _DrawerMenuItem(
              title: 'Map',
              onTap: () {
                Navigator.pop(context);
                ref.read(currentTabProvider.notifier).state = 0;
              },
            ),
            _DrawerMenuItem(
              title: 'Popular',
              onTap: () {
                Navigator.pop(context);
                ref.read(currentTabProvider.notifier).state = 1;
              },
            ),
            _DrawerMenuItem(
              title: 'Calendar',
              onTap: () {
                Navigator.pop(context);
                // Navigate to calendar (if separate page)
              },
            ),
            _DrawerMenuItem(
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                ref.read(currentTabProvider.notifier).state = 3;
              },
            ),
            _DrawerMenuItem(
              title: 'About us',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'About Travely',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Travely is your personal travel companion app. '
          'Discover new destinations, plan your routes, and create '
          'unforgettable travel memories.\n\nVersion 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Drawer menu item - matches Figma design
class _DrawerMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
