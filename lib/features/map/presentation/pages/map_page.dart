import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../excursion/presentation/providers/excursion_provider.dart';
import '../../data/places_service.dart';
import '../widgets/place_card.dart';

/// Provider for PlacesService
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

/// Provider for selected place
final selectedPlaceProvider = StateProvider<PlaceData?>((ref) => null);

/// Provider for map controller
final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

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
    name: "Swallow's nest",
    imageUrl:
        'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=800',
    openingHours: 'Open from 9:00 a.m. to 8:00 p.m',
    location: LatLng(44.430, 33.971),
    rating: 4.8,
  ),
  const PlaceData(
    id: '2',
    name: 'Kamianets Podilskyi',
    imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    openingHours: 'Open from 9:00 a.m. to 8:00 p.m',
    location: LatLng(48.6833, 26.5667),
    rating: 4.9,
  ),
  const PlaceData(
    id: '3',
    name: 'Lavender Fields',
    imageUrl:
        'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
    openingHours: 'Open from 6:00 a.m. to 10:00 p.m',
    location: LatLng(43.8333, 4.8),
    rating: 4.7,
  ),
];

/// Map page - matches Figma design with search bar
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
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
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

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

  @override
  Widget build(BuildContext context) {
    final selectedPlace = ref.watch(selectedPlaceProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 6,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              ref.read(mapControllerProvider.notifier).state = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) {
              ref.read(selectedPlaceProvider.notifier).state = null;
            },
          ),

          // Top bar with search and profile - matches Figma
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search bar with filter
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Search icon
                          const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(
                              Icons.search,
                              color: AppColors.textHint,
                              size: 24,
                            ),
                          ),
                          // Text field
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          // Filter button
                          GestureDetector(
                            onTap: () => _showFilterSheet(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // User avatar from Firebase
                  authState.when(
                    data: (user) => _buildUserAvatar(user?.photoUrl),
                    loading: () => _buildUserAvatar(null),
                    error: (_, __) => _buildUserAvatar(null),
                  ),
                ],
              ),
            ),
          ),

          // Selected place card at bottom
          if (selectedPlace != null)
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
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? photoUrl) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
        child: Text(
          'MC',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      final placesService = ref.read(placesServiceProvider);
      final authState = ref.read(authNotifierProvider);
      final userId = authState.value?.uid;

      // Generate excursion from filter
      final excursion = await placesService.generateExcursion(
        locationQuery: filter.locationQuery,
        destinationQuery: filter.destinationQuery,
        radiusKm: filter.radiusKm,
        selectedTypes: filter.selectedTypes,
        userId: userId,
      );

      if (excursion == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not find location. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Save to Firebase
      final success = await ref
          .read(excursionsProvider.notifier)
          .createExcursion(excursion);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excursion "${excursion.name}" created!'),
              backgroundColor: AppColors.success,
              action: SnackBarAction(
                label: 'View',
                textColor: AppColors.white,
                onPressed: () {
                  // Could navigate to excursion details or Popular page
                },
              ),
            ),
          );

          // Optionally move map to the destination
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
            const SnackBar(
              content: Text('Failed to save excursion. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Full-screen filter sheet – matches MAP-filter frame from Figma
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

  final Map<String, bool> _types = {
    'art gallery': true,
    'museum': true,
    'store': true,
    'church': false,
    'cafe': false,
    'park': true,
    'gym': true,
    'zoo': false,
    'aquarium': true,
  };

  @override
  void initState() {
    super.initState();
    _locationFocusNode.addListener(_onLocationFocusChange);
    _destinationFocusNode.addListener(_onDestinationFocusChange);
    // Show initial suggestions
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
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          height: size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Top drag handle
              Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location input with autocomplete
                      _buildLocationInput(),

                      const SizedBox(height: 16),

                      // Destination input with autocomplete
                      _buildDestinationInput(),

                      const SizedBox(height: 24),
                      const _FilterSectionTitle('Radius'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                min: 0.5,
                                max: 10,
                                value: _radiusKm,
                                activeColor: AppColors.textPrimary,
                                inactiveColor: AppColors.border,
                                onChanged: (value) {
                                  setState(() => _radiusKm = value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_radiusKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _FilterSectionTitle('Select type'),
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
                              setState(() {
                                _types[label] = !selected;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterActionPill(
                        label: 'OK',
                        onTap: _submitFilter,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FilterActionPill(
                        label: 'CANCEL',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.my_location_outlined,
                  color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  focusNode: _locationFocusNode,
                  onChanged: _updateLocationSuggestions,
                  decoration: const InputDecoration(
                    hintText: 'Enter your location',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Location suggestions dropdown
        if (_showLocationSuggestions && _locationSuggestions.isNotEmpty)
          _buildSuggestionsDropdown(
            _locationSuggestions,
            _selectLocation,
          ),
      ],
    );
  }

  Widget _buildDestinationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.place_outlined,
                  color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  focusNode: _destinationFocusNode,
                  onChanged: _updateDestinationSuggestions,
                  decoration: const InputDecoration(
                    hintText: 'Destination (optional)',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textPrimary, size: 18),
            ],
          ),
        ),
        // Destination suggestions dropdown
        if (_showDestinationSuggestions && _destinationSuggestions.isNotEmpty)
          _buildSuggestionsDropdown(
            _destinationSuggestions,
            _selectDestination,
          ),
      ],
    );
  }

  Widget _buildSuggestionsDropdown(
    List<PopularLocation> suggestions,
    void Function(PopularLocation) onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final location = suggestions[index];
          return InkWell(
            onTap: () => onSelect(location),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          location.country,
                          style: const TextStyle(
                            fontSize: 13,
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
    // Validate location is provided
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a location'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get selected types
    final selectedTypes =
        _types.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Build and return filter result
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

class _FilterActionPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterActionPill({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  final String text;

  const _FilterSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? AppColors.textPrimary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
