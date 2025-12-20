import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/map_page.dart';

/// Place card widget for map - matching Figma design
class PlaceCard extends StatelessWidget {
  final PlaceData place;
  final VoidCallback? onNavigate;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PlaceCard({
    super.key,
    required this.place,
    this.onNavigate,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: place.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: AppColors.textHint,
                ),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),

            // Content at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigation arrows and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      _ArrowButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: onPrevious,
                      ),

                      // Title
                      Expanded(
                        child: Center(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Next button
                      _ArrowButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        onTap: onNext,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Opening hours and navigate button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Navigate button
                      GestureDetector(
                        onTap: onNavigate,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Opening hours
                      Text(
                        place.openingHours,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 13,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arrow button for navigation
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 18,
        ),
      ),
    );
  }
}
