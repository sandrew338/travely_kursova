import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Splash screen with Travely logo - matches Figma design
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after splash
    Timer(const Duration(seconds: 3), () {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authNotifierProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          context.go('/main');
        } else {
          context.go('/onboarding');
        }
      },
      loading: () => context.go('/onboarding'),
      error: (_, __) => context.go('/onboarding'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE), // Light gray from Figma
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Travely logo image from assets
                      Image.asset(
                        'assets/images/travely.png',
                        width: 320,
                        height: 400,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image not found
                          return _buildFallbackLogo();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Traveler icon
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF5B7FFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.luggage,
            size: 100,
            color: Color(0xFF5B7FFF),
          ),
        ),
        const SizedBox(height: 32),
        // Travely text
        const Text(
          'Travely',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w400,
            fontFamily: 'Kanit',
            color: AppColors.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
