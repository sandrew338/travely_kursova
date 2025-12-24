import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../excursion/domain/entities/excursion_entity.dart';
import '../../../excursion/presentation/providers/excursion_provider.dart';
import '../../../home/presentation/pages/main_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../widgets/excursion_card.dart';

/// Popular/Explore page showing excursions grid - Figma design
class PopularPage extends ConsumerStatefulWidget {
  const PopularPage({super.key});

  @override
  ConsumerState<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends ConsumerState<PopularPage> {
  @override
  void initState() {
    super.initState();
    // Load popular excursions on init
    Future.microtask(() {
      ref.read(excursionsProvider.notifier).loadPopularExcursions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(excursionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const _PopularHeader(),

            // Content
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ExcursionsState state) {
    if (state.isLoading) {
      return const _LoadingGrid();
    }

    if (state.error != null) {
      return _ErrorView(
        message: state.error!,
        onRetry: () {
          ref.read(excursionsProvider.notifier).loadPopularExcursions();
        },
      );
    }

    if (state.excursions.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(excursionsProvider.notifier).loadPopularExcursions();
      },
      color: AppColors.primary,
      child: _ExcursionsGrid(excursions: state.excursions),
    );
  }
}

/// Header with title
class _PopularHeader extends StatelessWidget {
  const _PopularHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Популярні',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Kanit',
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of excursion cards
class _ExcursionsGrid extends ConsumerWidget {
  final List<ExcursionEntity> excursions;

  const _ExcursionsGrid({required this.excursions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: excursions.length,
      itemBuilder: (context, index) {
        final excursion = excursions[index];
        return ExcursionCard(
          excursion: excursion,
          onTap: () => _openExcursionDetails(context, ref, excursion),
        );
      },
    );
  }

  void _openExcursionDetails(
    BuildContext context,
    WidgetRef ref,
    ExcursionEntity excursion,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExcursionDetailsSheet(excursion: excursion),
    );
  }
}

/// Excursion details bottom sheet with distance validation
class _ExcursionDetailsSheet extends ConsumerWidget {
  final ExcursionEntity excursion;

  const _ExcursionDetailsSheet({required this.excursion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Image
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(excursion.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    excursion.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          excursion.destination,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.starFilled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        excursion.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Distance indicator
                  if (userLocation != null &&
                      excursion.destinationLatitude != null &&
                      excursion.destinationLongitude != null)
                    _buildDistanceInfo(userLocation),

                  const SizedBox(height: 16),
                  Text(
                    excursion.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Landmarks preview
                  if (excursion.landmarks.isNotEmpty) ...[
                    const Text(
                      'Зупинки маршруту',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...excursion.landmarks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final landmark = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                landmark.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: excursion.duration,
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.attach_money,
                        label: '\$${excursion.price.toInt()}',
                      ),
                      if (excursion.landmarks.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        _InfoChip(
                          icon: Icons.place,
                          label: '${excursion.landmarks.length} місць',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _handleBookNow(context, ref, userLocation),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Забронювати',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(LatLng userLocation) {
    final distance = GeoUtils.calculateDistanceKm(
      userLocation.latitude,
      userLocation.longitude,
      excursion.destinationLatitude!,
      excursion.destinationLongitude!,
    );

    // Anti-teleport check: 20km threshold
    final isTooFar = distance > 20;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            isTooFar ? Icons.warning_rounded : Icons.directions_walk,
            size: 16,
            color: isTooFar ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            '${GeoUtils.formatDistance(distance)} від вас',
            style: TextStyle(
              fontSize: 12,
              color: isTooFar ? AppColors.warning : AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isTooFar) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Далеко',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleBookNow(
    BuildContext context,
    WidgetRef ref,
    LatLng? userLocation,
  ) {
    // Anti-teleport distance validation (20km threshold)
    if (userLocation != null &&
        excursion.destinationLatitude != null &&
        excursion.destinationLongitude != null) {
      final distance = GeoUtils.calculateDistanceKm(
        userLocation.latitude,
        userLocation.longitude,
        excursion.destinationLatitude!,
        excursion.destinationLongitude!,
      );

      // Block if distance is > 20km - strict anti-teleport check
      if (distance > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Цей маршрут занадто далеко (${GeoUtils.formatDistance(distance)} > 20 км) від вашого поточного місцезнаходження.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Зрозуміло',
              textColor: AppColors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        return; // Block the action - do not proceed
      }
    }

    _proceedWithBooking(context, ref);
  }

  void _proceedWithBooking(BuildContext context, WidgetRef ref) {
    // Close the bottom sheet
    Navigator.pop(context);

    // Set the booked excursion to display on map
    ref.read(bookedExcursionProvider.notifier).state = excursion;

    // Navigate to map tab
    ref.read(currentTabProvider.notifier).state = 0;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Екскурсію "${excursion.name}" заброньовано!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading grid placeholder
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ой! Щось пішло не так',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати ще'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 80,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Екскурсій не знайдено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Перевірте пізніше, щоб знайти цікаві місця!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
