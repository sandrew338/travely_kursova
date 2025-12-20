import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../excursion/domain/entities/excursion_entity.dart';

/// Excursion card widget matching Figma design
class ExcursionCard extends StatelessWidget {
  final ExcursionEntity excursion;
  final VoidCallback? onTap;

  const ExcursionCard({
    super.key,
    required this.excursion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.15),
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
              // Background Image
              CachedNetworkImage(
                imageUrl: excursion.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariant,
                  highlightColor: AppColors.surface,
                  child: Container(color: AppColors.surfaceVariant),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textHint,
                    size: 40,
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x40000000),
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // Content at bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      excursion.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Star Rating
                    _StarRating(rating: excursion.rating),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Star rating widget
class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({
    required this.rating,
  });

  int get maxStars => 5;
  double get starSize => 14;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        return Icon(
          icon,
          color: AppColors.starFilled,
          size: starSize,
        );
      }),
    );
  }
}
