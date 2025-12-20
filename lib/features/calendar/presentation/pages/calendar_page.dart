import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

/// Calendar page - matches Figma design exactly
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  int _selectedDay = 14;
  String _viewMode = '2 weeks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Month selector
            _buildMonthSelector(),

            const SizedBox(height: 16),

            // Calendar grid
            _buildCalendarGrid(),

            const SizedBox(height: 24),

            // Upcoming trips section
            Expanded(
              child: _buildUpcomingTrips(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left arrow and month
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'May 24',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // View mode selector
          GestureDetector(
            onTap: _toggleViewMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _viewMode,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Right arrow
          GestureDetector(
            onTap: () {},
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar days
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildCalendarDays() {
    // May 2024 starts on Wednesday
    final List<int?> days = [
      null,
      null,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      29,
      30,
      31,
      null,
    ];

    return Column(
      children: List.generate(5, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final index = rowIndex * 7 + colIndex;
              final day = index < days.length ? days[index] : null;

              if (day == null) {
                return const SizedBox(width: 36, height: 36);
              }

              final isSelected = day == _selectedDay;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDay = day);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cardBackground
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.textSecondary, width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildUpcomingTrips() {
    // Empty state - no trips scheduled
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No trips scheduled',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add trips to see them here',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == '2 weeks' ? '1 month' : '2 weeks';
    });
  }
}
