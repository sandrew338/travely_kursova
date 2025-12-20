import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Onboarding/Welcome page
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Logo and illustration
                _buildIllustration(),
                const SizedBox(height: 48),
                // App name
                Text(
                  'Travely',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 16),
                // Tagline
                Text(
                  'Your Travel Companion',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover amazing places, plan your trips,\nand create unforgettable memories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textHint,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Buttons
                AppButton(
                  text: 'Get Started',
                  width: double.infinity,
                  onPressed: () => context.go(RouteNames.register),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'I already have an account',
                  width: double.infinity,
                  isOutlined: true,
                  onPressed: () => context.go(RouteNames.login),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Map background
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          // Traveler icon
          const Icon(
            Icons.travel_explore,
            size: 120,
            color: AppColors.primary,
          ),
          // Location pins
          Positioned(
            top: 50,
            right: 50,
            child: _buildLocationPin(AppColors.accent),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            child: _buildLocationPin(AppColors.secondary),
          ),
          Positioned(
            top: 80,
            left: 60,
            child: _buildLocationPin(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPin(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

