import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/main_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/routes/presentation/pages/routes_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import 'route_names.dart';

/// App router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Login
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Register
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main App (with bottom navigation)
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const MainPage(),
      ),
      // Alias /main route for navigation from splash
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainPage(),
      ),

      // History (Travel routes)
      GoRoute(
        path: RouteNames.routes,
        name: 'routes',
        builder: (context, state) => const RoutesPage(),
      ),

      // Calendar screen
      GoRoute(
        path: RouteNames.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
