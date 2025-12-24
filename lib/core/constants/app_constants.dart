/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Travely';
  static const String appVersion = '1.0.0';

  // API Keys (replace with your actual keys)
  static const String googleMapsApiKey =
      'AIzaSyBiGQanFXhjlQ5QLTqjrr7OTit6l4W5ZbA';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String excursionsCollection = 'Excursions';
  static const String routesCollection = 'Routes';
  static const String landmarksCollection = 'Landmarks';
  static const String reviewsCollection = 'Reviews';
  static const String savedPlacesCollection = 'Saved_places';

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Map Settings
  static const double defaultZoom = 14.0;
  static const double defaultLatitude = 48.8566; // Paris
  static const double defaultLongitude = 2.3522;
}
