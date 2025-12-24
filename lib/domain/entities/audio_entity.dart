import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Audio guide entity - domain layer
class AudioEntity extends Equatable {
  final String id;
  final String title;
  final String fileUrl;
  final Duration duration;
  final String language;
  final AudioPriority priority;
  final String? relatedLandmarkId;
  final double? fileSize;

  const AudioEntity({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.duration,
    required this.language,
    required this.priority,
    this.relatedLandmarkId,
    this.fileSize,
  });

  /// Empty audio
  static const empty = AudioEntity(
    id: '',
    title: '',
    fileUrl: '',
    duration: Duration.zero,
    language: 'ua',
    priority: AudioPriority.medium,
  );

  /// Check if audio is empty
  bool get isEmpty => this == AudioEntity.empty;

  /// Check if audio is not empty
  bool get isNotEmpty => this != AudioEntity.empty;

  /// Get formatted duration string (e.g., "3:45")
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size (e.g., "2.5 MB")
  String? get formattedFileSize {
    if (fileSize == null) return null;
    if (fileSize! < 1) {
      return '${(fileSize! * 1024).toStringAsFixed(0)} KB';
    }
    return '${fileSize!.toStringAsFixed(1)} MB';
  }

  /// Get language display name
  String get languageDisplayName {
    switch (language.toLowerCase()) {
      case 'ua':
        return 'Українська';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'pl':
        return 'Polski';
      default:
        return language.toUpperCase();
    }
  }

  /// Copy with method
  AudioEntity copyWith({
    String? id,
    String? title,
    String? fileUrl,
    Duration? duration,
    String? language,
    AudioPriority? priority,
    String? relatedLandmarkId,
    double? fileSize,
  }) {
    return AudioEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      fileUrl: fileUrl ?? this.fileUrl,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      priority: priority ?? this.priority,
      relatedLandmarkId: relatedLandmarkId ?? this.relatedLandmarkId,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        fileUrl,
        duration,
        language,
        priority,
        relatedLandmarkId,
        fileSize,
      ];
}
