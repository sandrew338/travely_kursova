import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../excursion/domain/entities/excursion_entity.dart';
import '../../../excursion/presentation/providers/excursion_provider.dart';
import '../../../home/presentation/pages/main_page.dart';
import '../../data/directions_service.dart';
import '../../data/places_service.dart';
import '../widgets/place_card.dart';

/// Provider for DirectionsService
final directionsServiceProvider = Provider<DirectionsService>((ref) {
  return DirectionsService();
});

/// Provider for PlacesService
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

/// Provider for selected place
final selectedPlaceProvider = StateProvider<PlaceData?>((ref) => null);

/// Provider for map controller
final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

/// Provider for currently booked/active excursion to display on map
final bookedExcursionProvider = StateProvider<ExcursionEntity?>((ref) => null);

/// Provider for current user location
final userLocationProvider = StateProvider<LatLng?>((ref) => null);

/// Provider for selected filter types
final selectedFiltersProvider = StateProvider<Set<String>>((ref) => {
      'музей',
      'парк',
      'кафе',
    });

/// Simple place data class
class PlaceData {
  final String id;
  final String name;
  final String imageUrl;
  final String openingHours;
  final LatLng location;
  final double rating;

  const PlaceData({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.openingHours,
    required this.location,
    required this.rating,
  });
}

/// Sample places data
final samplePlaces = [
  const PlaceData(
    id: '1',
    name: "Ластівчине гніздо",
    imageUrl:
        'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=800',
    openingHours: 'Відкрито з 9:00 до 20:00',
    location: LatLng(44.430, 33.971),
    rating: 4.8,
  ),
  const PlaceData(
    id: '2',
    name: "Кам'янець-Подільський",
    imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    openingHours: 'Відкрито з 9:00 до 20:00',
    location: LatLng(48.6833, 26.5667),
    rating: 4.9,
  ),
  const PlaceData(
    id: '3',
    name: 'Лавандові поля',
    imageUrl:
        'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
    openingHours: 'Відкрито з 6:00 до 22:00',
    location: LatLng(43.8333, 4.8),
    rating: 4.7,
  ),
];

/// Available filter types for quick access
const List<String> quickFilterTypes = [
  'музей',
  'парк',
  'кафе',
  'церква',
  'магазин',
  'зоопарк',
];

/// Map page with route display and excursion visualization
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(48.3794, 31.1656);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialPosition = location;
        _isLoading = false;
      });

      // Store user location in provider for distance calculations
      ref.read(userLocationProvider.notifier).state = location;

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers = samplePlaces.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _selectPlace(place),
      );
    }).toSet();
  }

  void _selectPlace(PlaceData place) {
    ref.read(selectedPlaceProvider.notifier).state = place;
  }

  void _openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  /// Display excursion route on map with markers and real road polyline
  Future<void> _displayExcursionRoute(ExcursionEntity excursion) async {
    // Clear existing markers and polylines
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    if (excursion.landmarks.isEmpty) {
      if (excursion.destinationLatitude != null &&
          excursion.destinationLongitude != null) {
        setState(() {
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(
              excursion.destinationLatitude!,
              excursion.destinationLongitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: excursion.destination,
              snippet: excursion.name,
            ),
          ));
        });
      }
      return;
    }

    final List<LatLng> routePoints = [];

    // Add markers for each landmark
    for (int i = 0; i < excursion.landmarks.length; i++) {
      final landmark = excursion.landmarks[i];
      final position = LatLng(landmark.latitude, landmark.longitude);
      routePoints.add(position);
    }

    setState(() {
      for (int i = 0; i < excursion.landmarks.length; i++) {
        final landmark = excursion.landmarks[i];
        final position = LatLng(landmark.latitude, landmark.longitude);

        _markers.add(Marker(
          markerId: MarkerId('landmark_$i'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0
                ? BitmapDescriptor.hueGreen
                : i == excursion.landmarks.length - 1
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: '${i + 1}. ${landmark.name}',
            snippet: landmark.description ?? '',
          ),
        ));
      }
    });

    // Fetch real road polyline from Directions API
    if (routePoints.length >= 2) {
      final directionsService = ref.read(directionsServiceProvider);

      final directionsResult = await directionsService.fetchRoutePolyline(
        points: routePoints,
        mode: 'walking',
      );

      if (directionsResult != null && mounted) {
        setState(() {
          // Draw the actual road-following polyline
          _polylines.add(Polyline(
            polylineId: const PolylineId('excursion_route'),
            points: directionsResult.polylinePoints,
            color: AppColors.primary,
            width: 5,
            // Solid line for real roads (no dashes)
          ));
        });
      } else if (mounted) {
        // Fallback to straight lines if API fails
        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('excursion_route'),
            points: routePoints,
            color: AppColors.primary,
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ));
        });
      }
    }

    _fitMapToMarkers();
  }

  void _fitMapToMarkers() {
    if (_markers.isEmpty || _mapController == null) return;

    final positions = _markers.map((m) => m.position).toList();

    if (positions.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(positions.first, 14),
      );
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _clearExcursionRoute() {
    ref.read(bookedExcursionProvider.notifier).state = null;
    setState(() {
      _polylines.clear();
      _createMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlace = ref.watch(selectedPlaceProvider);
    final authState = ref.watch(authNotifierProvider);
    final bookedExcursion = ref.watch(bookedExcursionProvider);
    final selectedFilters = ref.watch(selectedFiltersProvider);

    if (bookedExcursion != null && _polylines.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _displayExcursionRoute(bookedExcursion);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Google Map (background layer)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 6,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              ref.read(mapControllerProvider.notifier).state = controller;

              final booked = ref.read(bookedExcursionProvider);
              if (booked != null) {
                _displayExcursionRoute(booked);
              }
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) {
              ref.read(selectedPlaceProvider.notifier).state = null;
            },
          ),

          // Top UI overlay with search and filters
          SafeArea(
            child: Column(
              children: [
                // Search bar row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Main search bar container with elevated design
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Menu button
                              GestureDetector(
                                onTap: _openDrawer,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(left: 4),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: AppColors.textPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                              // Vertical divider
                              Container(
                                width: 1,
                                height: 26,
                                color: AppColors.divider,
                              ),
                              // Search text field
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.search,
                                  decoration: const InputDecoration(
                                    hintText: 'Пошук...',
                                    filled: true,
                                    fillColor: AppColors.white,
                                    hintStyle: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onSubmitted: (value) {
                                    // Handle search
                                  },
                                ),
                              ),
                              // Filter button (opens full filter sheet)
                              GestureDetector(
                                onTap: () => _showFilterSheet(context),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/filter.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.textSecondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // User avatar with shadow
                      authState.when(
                        data: (user) => _buildUserAvatar(user?.photoUrl),
                        loading: () => _buildUserAvatar(null),
                        error: (_, __) => _buildUserAvatar(null),
                      ),
                    ],
                  ),
                ),

                // Quick filter chips (horizontally scrollable)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: quickFilterTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final type = quickFilterTypes[index];
                      final isSelected = selectedFilters.contains(type);
                      return _QuickFilterChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () {
                          final filters = Set<String>.from(
                              ref.read(selectedFiltersProvider));
                          if (isSelected) {
                            filters.remove(type);
                          } else {
                            filters.add(type);
                          }
                          ref.read(selectedFiltersProvider.notifier).state =
                              filters;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Active excursion banner
          if (bookedExcursion != null)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 120,
              child: _ExcursionRouteBanner(
                excursion: bookedExcursion,
                onClose: _clearExcursionRoute,
              ),
            ),

          // Selected place card at bottom
          if (selectedPlace != null && bookedExcursion == null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: PlaceCard(
                place: selectedPlace,
                onNavigate: () => _navigateToPlace(selectedPlace),
                onPrevious: () => _navigateToPreviousPlace(),
                onNext: () => _navigateToNextPlace(),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: AppColors.background.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? photoUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildAvatarPlaceholder(),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }

  void _navigateToPlace(PlaceData place) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(place.location, 14),
    );
  }

  void _navigateToPreviousPlace() {
    final currentPlace = ref.read(selectedPlaceProvider);
    if (currentPlace == null) return;

    final currentIndex =
        samplePlaces.indexWhere((p) => p.id == currentPlace.id);
    if (currentIndex > 0) {
      final previousPlace = samplePlaces[currentIndex - 1];
      ref.read(selectedPlaceProvider.notifier).state = previousPlace;
      _navigateToPlace(previousPlace);
    }
  }

  void _navigateToNextPlace() {
    final currentPlace = ref.read(selectedPlaceProvider);
    if (currentPlace == null) return;

    final currentIndex =
        samplePlaces.indexWhere((p) => p.id == currentPlace.id);
    if (currentIndex < samplePlaces.length - 1) {
      final nextPlace = samplePlaces[currentIndex + 1];
      ref.read(selectedPlaceProvider.notifier).state = nextPlace;
      _navigateToPlace(nextPlace);
    }
  }

  void _showFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterSheet(),
    );

    if (result != null && mounted) {
      await _generateExcursionFromFilter(result);
    }
  }

  Future<void> _generateExcursionFromFilter(FilterResult filter) async {
    setState(() => _isLoading = true);

    try {
      final placesService = ref.read(placesServiceProvider);
      final authState = ref.read(authNotifierProvider);
      final userId = authState.value?.uid;
      final userLocation = ref.read(userLocationProvider);

      // Use validation-aware generation
      final result = await placesService.generateExcursionWithValidation(
        locationQuery: filter.locationQuery,
        destinationQuery: filter.destinationQuery,
        radiusKm: filter.radiusKm,
        selectedTypes: filter.selectedTypes,
        userId: userId,
        userLocation: userLocation,
      );

      // Check validation result
      if (!result.isValid) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result.errorMessage ?? 'Помилка генерації маршруту'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      final excursion = result.excursion;
      if (excursion == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Не вдалося знайти локацію. Спробуйте ще раз.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      final success = await ref
          .read(excursionsProvider.notifier)
          .createExcursion(excursion);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Екскурсію "${excursion.name}" створено!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'Переглянути',
                textColor: AppColors.white,
                onPressed: () {
                  ref.read(currentTabProvider.notifier).state = 1;
                },
              ),
            ),
          );

          final destination = await placesService.geocode(
            filter.destinationQuery ?? filter.locationQuery,
          );
          if (destination != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(destination, 12),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Не вдалося зберегти екскурсію. Спробуйте ще раз.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

/// Quick filter chip widget for horizontal list
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.inputBackgroundLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(isSelected ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Banner showing active excursion route
class _ExcursionRouteBanner extends StatelessWidget {
  final ExcursionEntity excursion;
  final VoidCallback onClose;

  const _ExcursionRouteBanner({
    required this.excursion,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_walk_rounded,
            color: AppColors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  excursion.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${excursion.landmarks.length} зупинок • ${excursion.duration}',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.white,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Premium filter bottom sheet with modern design
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  double _radiusKm = 1.5;
  List<PopularLocation> _locationSuggestions = [];
  List<PopularLocation> _destinationSuggestions = [];
  bool _showLocationSuggestions = false;
  bool _showDestinationSuggestions = false;

  // All filter types default to false (unchecked)
  final Map<String, bool> _types = {
    'арт-галерея': false,
    'музей': false,
    'магазин': false,
    'церква': false,
    'кафе': false,
    'парк': false,
    'спортзал': false,
    'зоопарк': false,
    'акваріум': false,
  };

  // Map Ukrainian names to API types
  static const Map<String, String> _typeMapping = {
    'арт-галерея': 'art gallery',
    'музей': 'museum',
    'магазин': 'store',
    'церква': 'church',
    'кафе': 'cafe',
    'парк': 'park',
    'спортзал': 'gym',
    'зоопарк': 'zoo',
    'акваріум': 'aquarium',
  };

  @override
  void initState() {
    super.initState();
    _locationFocusNode.addListener(_onLocationFocusChange);
    _destinationFocusNode.addListener(_onDestinationFocusChange);
    _updateLocationSuggestions('');
    _updateDestinationSuggestions('');
  }

  @override
  void dispose() {
    _locationController.dispose();
    _destinationController.dispose();
    _locationFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onLocationFocusChange() {
    setState(() {
      _showLocationSuggestions = _locationFocusNode.hasFocus;
      if (_locationFocusNode.hasFocus) {
        _showDestinationSuggestions = false;
      }
    });
  }

  void _onDestinationFocusChange() {
    setState(() {
      _showDestinationSuggestions = _destinationFocusNode.hasFocus;
      if (_destinationFocusNode.hasFocus) {
        _showLocationSuggestions = false;
      }
    });
  }

  void _updateLocationSuggestions(String query) {
    final placesService = ref.read(placesServiceProvider);
    setState(() {
      _locationSuggestions = placesService.getAutocompleteSuggestions(query);
    });
  }

  void _updateDestinationSuggestions(String query) {
    final placesService = ref.read(placesServiceProvider);
    setState(() {
      _destinationSuggestions = placesService.getAutocompleteSuggestions(query);
    });
  }

  void _selectLocation(PopularLocation location) {
    _locationController.text = location.displayName;
    setState(() => _showLocationSuggestions = false);
    _locationFocusNode.unfocus();
  }

  void _selectDestination(PopularLocation location) {
    _destinationController.text = location.displayName;
    setState(() => _showDestinationSuggestions = false);
    _destinationFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 60,
        bottom: bottomPadding > 0 ? bottomPadding : 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackgroundLight,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Створити екскурсію',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location input
                    _buildInputField(
                      controller: _locationController,
                      focusNode: _locationFocusNode,
                      hint: 'Введіть вашу локацію',
                      icon: Icons.my_location_rounded,
                      onChanged: _updateLocationSuggestions,
                    ),
                    if (_showLocationSuggestions &&
                        _locationSuggestions.isNotEmpty)
                      _buildSuggestionsDropdown(
                        _locationSuggestions,
                        _selectLocation,
                      ),

                    const SizedBox(height: 12),

                    // Destination input
                    _buildInputField(
                      controller: _destinationController,
                      focusNode: _destinationFocusNode,
                      hint: "Пункт призначення (необов'язково)",
                      icon: Icons.place_outlined,
                      suffixIcon: Icons.arrow_forward_ios_rounded,
                      onChanged: _updateDestinationSuggestions,
                    ),
                    if (_showDestinationSuggestions &&
                        _destinationSuggestions.isNotEmpty)
                      _buildSuggestionsDropdown(
                        _destinationSuggestions,
                        _selectDestination,
                      ),

                    const SizedBox(height: 24),

                    // Radius section
                    const Text(
                      'Радіус',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: _CustomThumbShape(),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20,
                              ),
                              trackShape: const RoundedRectSliderTrackShape(),
                            ),
                            child: Slider(
                              min: 0.5,
                              max: 20,
                              value: _radiusKm,
                              activeColor: AppColors.textPrimary,
                              inactiveColor: AppColors.inputBackground,
                              onChanged: (value) {
                                setState(() => _radiusKm = value);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_radiusKm.toStringAsFixed(1)} км',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Type selection
                    const Text(
                      'Оберіть тип',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.entries.map((entry) {
                        final label = entry.key;
                        final selected = entry.value;
                        return _TypeChip(
                          label: label,
                          selected: selected,
                          onTap: () {
                            setState(() => _types[label] = !selected);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'OK',
                      isPrimary: true,
                      onTap: _submitFilter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'CANCEL',
                      isPrimary: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: AppColors.white,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          if (suffixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(suffixIcon, color: AppColors.textSecondary, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown(
    List<PopularLocation> suggestions,
    void Function(PopularLocation) onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final location = suggestions[index];
          return InkWell(
            onTap: () => onSelect(location),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          location.country,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitFilter() {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Будь ласка, введіть локацію'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Convert Ukrainian type names to API types
    final selectedTypes = _types.entries
        .where((e) => e.value)
        .map((e) => _typeMapping[e.key] ?? e.key)
        .toList();

    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Будь ласка, оберіть хоча б один тип'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final result = FilterResult(
      locationQuery: location,
      destinationQuery: _destinationController.text.trim().isEmpty
          ? null
          : _destinationController.text.trim(),
      radiusKm: _radiusKm,
      selectedTypes: selectedTypes,
    );

    Navigator.of(context).pop(result);
  }
}

/// Custom slider thumb shape
class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer circle (border)
    canvas.drawCircle(
      center,
      12,
      Paint()..color = AppColors.textPrimary,
    );

    // Inner circle
    canvas.drawCircle(
      center,
      10,
      Paint()..color = AppColors.inputBackground,
    );
  }
}

/// Type selection chip
class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: AppColors.textPrimary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.textPrimary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.textPrimary : AppColors.textHint,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button for filter sheet
class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.textPrimary : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
