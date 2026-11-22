import '../entities/lesson_progress.dart';

abstract interface class ProgressRepository {
  Stream<List<LessonProgress>> watchProgress(int profileId);

  Future<List<LessonProgress>> getProgress(int profileId);

  /// Saves a result without ever lowering previously earned stars or clearing a
  /// completed checkmark.
  Future<void> saveResult({
    required int profileId,
    required String lessonId,
    required int stars,
    required bool completed,
  });

  /// Unlocks a sticker for the child profile. Idempotent.
  Future<void> unlockSticker({
    required int profileId,
    required String stickerId,
  });

  /// Streams the list of unlocked sticker IDs for the given profile.
  Stream<List<String>> watchUnlockedStickers(int profileId);

  /// Returns the list of unlocked sticker IDs for the given profile.
  Future<List<String>> getUnlockedStickers(int profileId);
}
