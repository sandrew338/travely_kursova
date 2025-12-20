import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile page - matches Figma design with real Firebase data
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: authState.when(
          data: (user) => _buildProfileContent(context, ref, user),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Title
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // User avatar from Firebase
          _buildAvatar(user?.photoUrl, user?.name ?? ''),

          const SizedBox(height: 16),

          // User name from Firebase
          Text(
            user?.name ?? 'Guest User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // User email from Firebase
          Text(
            user?.email ?? 'No email',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Stats row
          _buildStatsRow(),

          const SizedBox(height: 32),

          // Menu items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Calendar',
                  onTap: () => context.push(RouteNames.calendar),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Support',
                  onTap: () => _showSupportDialog(context),
                ),
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Pro-version',
                  onTap: () => _showProVersionDialog(context),
                ),
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Moderation',
                  onTap: () => _showModerationDialog(context),
                ),
                _MenuItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () => _signOut(context, ref),
                  isDestructive: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, String name) {
    // Get initials from name
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'U';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                placeholder: (context, url) => _buildInitialsAvatar(initials),
                errorWidget: (context, url, error) =>
                    _buildInitialsAvatar(initials),
              )
            : _buildInitialsAvatar(initials),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(value: '12', label: 'Trips'),
        Container(width: 1, height: 40, color: AppColors.border),
        _StatItem(value: '8', label: 'Countries'),
        Container(width: 1, height: 40, color: AppColors.border),
        _StatItem(value: '24', label: 'Places'),
      ],
    );
  }

  void _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) {
      context.go('/onboarding');
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Support', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Need help? Contact us at:\n\nsupport@travely.app\n\n'
          'Or visit our FAQ section on the website.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProVersionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pro-version', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Unlock premium features:\n\n'
          '• Unlimited saved places\n'
          '• Offline maps\n'
          '• Ad-free experience\n'
          '• Priority support\n\n'
          'Coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showModerationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Go to the moderator menu?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Moderation access granted')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('yes'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('no'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Menu item widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDestructive ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? AppColors.error : AppColors.textHint,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
