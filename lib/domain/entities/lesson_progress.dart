import 'package:equatable/equatable.dart';

/// Saved local progress for one lesson and one child profile.
class LessonProgress extends Equatable {
  const LessonProgress({
    required this.profileId,
    required this.lessonId,
    required this.completed,
    required this.stars,
    required this.updatedAt,
  });

  final int profileId;
  final String lessonId;
  final bool completed;
  final int stars;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [profileId, lessonId, completed, stars, updatedAt];
}
