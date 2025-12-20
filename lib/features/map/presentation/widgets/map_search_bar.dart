import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Search bar for map - matching Figma design
class MapSearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearch;

  const MapSearchBar({
    super.key,
    this.onFilterTap,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Search text field
          Expanded(
            child: TextField(
              onChanged: onSearch,
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),

          // Filter button
          GestureDetector(
            onTap: onFilterTap,
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

          // User avatar
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'RT',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

