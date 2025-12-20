/// Route names for navigation
class RouteNames {
  RouteNames._();

  // Splash
  static const String splash = '/';

  // Auth Routes
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Main Routes
  static const String home = '/main';
  static const String map = '/map';
  static const String popular = '/popular';
  static const String calendar = '/calendar';
  static const String routes = '/routes';
  static const String profile = '/profile';

  // Detail Routes
  static const String placeDetail = '/place/:id';
  static const String excursionDetail = '/excursion/:id';
  static const String routeDetail = '/route/:id';

  // Settings
  static const String settings = '/settings';
  static const String preferences = '/preferences';
}
