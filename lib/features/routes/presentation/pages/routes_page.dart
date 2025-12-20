import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

/// History page - matches Figma design exactly
class RoutesPage extends ConsumerWidget {
  const RoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Traveled routes card
                    _HistoryCard(
                      title: 'Traveled\nroutes',
                      imageUrl:
                          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
                      onTap: () => _openTraveledRoutes(context),
                    ),

                    const SizedBox(height: 24),

                    // Selected routes card
                    _HistoryCard(
                      title: 'Selected routs',
                      imageUrl:
                          'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
                      onTap: () => _openSelectedRoutes(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTraveledRoutes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _TraveledRoutesPage()),
    );
  }

  void _openSelectedRoutes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SelectedRoutesPage()),
    );
  }
}

/// History card widget - matches Figma design
class _HistoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with opacity
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.grey.withOpacity(0.3),
                  BlendMode.saturation,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),

              // Semi-transparent overlay
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),

              // Title centered
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Traveled Routes Page - matches Figma design
class _TraveledRoutesPage extends StatelessWidget {
  const _TraveledRoutesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Traveled routs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _RouteListItem(
            name: 'Lake joy',
            imageUrl:
                'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=400',
            isFavorite: true,
          ),
          SizedBox(height: 12),
          _RouteListItem(
            name: 'Kamianets Podilsk',
            imageUrl:
                'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400',
            isFavorite: true,
          ),
          SizedBox(height: 12),
          _RouteListItem(
            name: 'Beautiful houses',
            imageUrl:
                'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
            isFavorite: true,
          ),
          SizedBox(height: 12),
          _RouteListItem(
            name: 'Lavender Fields',
            imageUrl:
                'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400',
            isFavorite: true,
          ),
          SizedBox(height: 12),
          _RouteListItem(
            name: 'Lavender',
            imageUrl:
                'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=400',
            isFavorite: true,
          ),
        ],
      ),
    );
  }
}

/// Selected Routes Page
class _SelectedRoutesPage extends StatelessWidget {
  const _SelectedRoutesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Selected routes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RouteListItem(
              name: 'Route ${index + 1}',
              imageUrl:
                  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
              isFavorite: false,
              showPlayButton: true,
            ),
          );
        },
      ),
    );
  }
}

/// Route list item widget - matches Figma design
class _RouteListItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isFavorite;
  final bool showPlayButton;

  const _RouteListItem({
    required this.name,
    required this.imageUrl,
    this.isFavorite = false,
    this.showPlayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Circular image
          ClipOval(
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.surfaceVariant,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Action button
          if (showPlayButton)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.white,
                size: 20,
              ),
            )
          else
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : AppColors.textHint,
              size: 24,
            ),
        ],
      ),
    );
  }
}
