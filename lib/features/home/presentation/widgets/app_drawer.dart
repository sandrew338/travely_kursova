import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../pages/main_page.dart';

/// Premium side drawer menu with modern design
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      width: MediaQuery.of(context).size.width * 0.78,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  // Logo icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.explore_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // App name
                  const Text(
                    'Travely',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Kanit',
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // User profile section
            authState.when(
              data: (user) => _UserProfileSection(
                userName: user?.name ?? 'Guest',
                userEmail: user?.email ?? '',
                photoUrl: user?.photoUrl,
              ),
              loading: () => const _UserProfileSection(
                userName: 'Loading...',
                userEmail: '',
                photoUrl: null,
              ),
              error: (_, __) => const _UserProfileSection(
                userName: 'Guest',
                userEmail: '',
                photoUrl: null,
              ),
            ),

            const SizedBox(height: 16),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 1,
                color: AppColors.divider,
              ),
            ),

            const SizedBox(height: 16),

            // Navigation Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _DrawerNavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      title: 'Map',
                      isActive: ref.watch(currentTabProvider) == 0,
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(currentTabProvider.notifier).state = 0;
                      },
                    ),
                    _DrawerNavItem(
                      icon: Icons.local_fire_department_outlined,
                      activeIcon: Icons.local_fire_department_rounded,
                      title: 'Popular',
                      isActive: ref.watch(currentTabProvider) == 1,
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(currentTabProvider.notifier).state = 1;
                      },
                    ),
                    _DrawerNavItem(
                      icon: Icons.history_outlined,
                      activeIcon: Icons.history_rounded,
                      title: 'History',
                      isActive: ref.watch(currentTabProvider) == 2,
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(currentTabProvider.notifier).state = 2;
                      },
                    ),
                    _DrawerNavItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today_rounded,
                      title: 'Calendar',
                      isActive: false,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RouteNames.calendar);
                      },
                    ),
                    _DrawerNavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      title: 'Profile',
                      isActive: ref.watch(currentTabProvider) == 3,
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(currentTabProvider.notifier).state = 3;
                      },
                    ),

                    const Spacer(),

                    // About section
                    _DrawerNavItem(
                      icon: Icons.info_outline_rounded,
                      activeIcon: Icons.info_rounded,
                      title: 'About us',
                      isActive: false,
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),

                    // Sign out
                    authState.when(
                      data: (user) => user != null
                          ? _DrawerNavItem(
                              icon: Icons.logout_rounded,
                              activeIcon: Icons.logout_rounded,
                              title: 'Sign Out',
                              isActive: false,
                              isDestructive: true,
                              onTap: () async {
                                Navigator.pop(context);
                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .signOut();
                                if (context.mounted) {
                                  context.go(RouteNames.login);
                                }
                              },
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Version info
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'About Travely',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Travely is your personal travel companion app. '
          'Discover new destinations, plan your routes, generate '
          'custom excursions, and create unforgettable travel memories.\n\n'
          'Version 1.0.0',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// User profile section in drawer
class _UserProfileSection extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? photoUrl;

  const _UserProfileSection({
    required this.userName,
    required this.userEmail,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              image: photoUrl != null && photoUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null || photoUrl!.isEmpty
                ? Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single drawer navigation item
class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: color,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
