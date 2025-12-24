import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Review entity - domain layer
class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String targetId;
  final ReviewType type;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.type,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  /// Empty review
  static final empty = ReviewEntity(
    id: '',
    userId: '',
    targetId: '',
    type: ReviewType.excursion,
    rating: 0.0,
    comment: '',
    images: const [],
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Check if review is empty
  bool get isEmpty => id.isEmpty;

  /// Check if review is not empty
  bool get isNotEmpty => id.isNotEmpty;

  /// Check if review has images
  bool get hasImages => images.isNotEmpty;

  /// Get star rating as integer (1-5)
  int get starRating => rating.round().clamp(1, 5);

  /// Check if rating is positive (>= 4)
  bool get isPositive => rating >= 4.0;

  /// Check if rating is negative (<= 2)
  bool get isNegative => rating <= 2.0;

  /// Get formatted rating string (e.g., "4.5")
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get time ago string for createdAt
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'рік' : 'років'} тому';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'місяць' : 'місяців'} тому';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'день' : 'днів'} тому';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'годину' : 'годин'} тому';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'хвилину' : 'хвилин'} тому';
    } else {
      return 'Щойно';
    }
  }

  /// Copy with method
  ReviewEntity copyWith({
    String? id,
    String? userId,
    String? targetId,
    ReviewType? type,
    double? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        targetId,
        type,
        rating,
        comment,
        images,
        createdAt,
      ];
}

